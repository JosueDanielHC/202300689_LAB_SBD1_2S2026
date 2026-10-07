-- Triggers y vistas de la Fase 2.
-- Se ejecuta al final de init.sql, cuando el dataset ya esta cargado.
-- CREATE OR ALTER permite volver a aplicarlo sobre una base ya existente.

USE ComercialLaEstrella;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER TRIGGER Insert_Detalle
ON detalle_venta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT v.id_tienda, i.id_producto, SUM(i.cantidad) AS cantidad
            FROM inserted AS i
            INNER JOIN venta AS v ON v.id_venta = i.id_venta
            GROUP BY v.id_tienda, i.id_producto
        ) AS pedido
        LEFT JOIN catalogo_producto AS c
            ON c.id_tienda = pedido.id_tienda
           AND c.id_producto = pedido.id_producto
        WHERE c.id_producto IS NULL
           OR pedido.cantidad > c.existencia_actual
    )
    BEGIN
        RAISERROR('Stock insuficiente', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE c
    SET c.existencia_actual = c.existencia_actual - pedido.cantidad
    FROM catalogo_producto AS c
    INNER JOIN (
        SELECT v.id_tienda, i.id_producto, SUM(i.cantidad) AS cantidad
        FROM inserted AS i
        INNER JOIN venta AS v ON v.id_venta = i.id_venta
        GROUP BY v.id_tienda, i.id_producto
    ) AS pedido
        ON pedido.id_tienda = c.id_tienda
       AND pedido.id_producto = c.id_producto;
END;
GO

CREATE OR ALTER TRIGGER Insert_Pago
ON pago
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE v
    SET v.id_estado_venta = pagada.id_estado_venta
    FROM venta AS v
    INNER JOIN (
        SELECT DISTINCT id_venta
        FROM inserted
    ) AS afectados ON afectados.id_venta = v.id_venta
    INNER JOIN estado_venta AS actual ON actual.id_estado_venta = v.id_estado_venta
    INNER JOIN estado_venta AS pagada ON pagada.nombre_estado_venta = 'PAGADA'
    WHERE actual.nombre_estado_venta = 'REGISTRADA'
      AND (
            SELECT ISNULL(SUM(p.monto), 0)
            FROM pago AS p
            WHERE p.id_venta = v.id_venta
          ) >= (
            SELECT ISNULL(SUM(d.subtotal), 0)
            FROM detalle_venta AS d
            WHERE d.id_venta = v.id_venta
          );
END;
GO

CREATE OR ALTER VIEW Vista_Ventas_Ubicacion
AS
SELECT
    t.nombre_tienda,
    m.nombre_municipio,
    dep.nombre_departamento,
    pa.nombre_pais,
    COUNT(v.id_venta) AS cantidad_ventas,
    ISNULL(SUM(tot.total_venta), 0) AS total_facturado
FROM tienda AS t
INNER JOIN municipio AS m ON m.id_municipio = t.id_municipio
INNER JOIN departamento AS dep ON dep.id_departamento = m.id_departamento
INNER JOIN pais AS pa ON pa.id_pais = dep.id_pais
LEFT JOIN venta AS v
    ON v.id_tienda = t.id_tienda
   AND v.id_estado_venta <> (
        SELECT id_estado_venta
        FROM estado_venta
        WHERE nombre_estado_venta = 'ANULADA'
   )
LEFT JOIN (
    SELECT id_venta, SUM(subtotal) AS total_venta
    FROM detalle_venta
    GROUP BY id_venta
) AS tot ON tot.id_venta = v.id_venta
GROUP BY
    t.nombre_tienda,
    m.nombre_municipio,
    dep.nombre_departamento,
    pa.nombre_pais;
GO

CREATE OR ALTER VIEW Vista_Top_Productos
AS
SELECT
    pr.id_producto AS codigo_producto,
    pr.nombre_producto,
    c.nombre_categoria,
    ma.nombre_marca,
    SUM(dv.cantidad) AS unidades_totales_vendidas,
    SUM(dv.subtotal) AS monto_total_generado
FROM detalle_venta AS dv
INNER JOIN venta AS v ON v.id_venta = dv.id_venta
INNER JOIN estado_venta AS ev ON ev.id_estado_venta = v.id_estado_venta
INNER JOIN producto AS pr ON pr.id_producto = dv.id_producto
INNER JOIN categoria AS c ON c.id_categoria = pr.id_categoria
INNER JOIN marca AS ma ON ma.id_marca = pr.id_marca
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY
    pr.id_producto,
    pr.nombre_producto,
    c.nombre_categoria,
    ma.nombre_marca;
GO

CREATE OR ALTER VIEW Vista_Saldos_Pendientes
AS
SELECT
    v.id_venta,
    ISNULL(det.total_venta, 0) AS total_venta,
    ISNULL(pag.monto_pagado, 0) AS monto_pagado,
    ISNULL(det.total_venta, 0) - ISNULL(pag.monto_pagado, 0) AS saldo_pendiente
FROM venta AS v
INNER JOIN estado_venta AS ev ON ev.id_estado_venta = v.id_estado_venta
LEFT JOIN (
    SELECT id_venta, SUM(subtotal) AS total_venta
    FROM detalle_venta
    GROUP BY id_venta
) AS det ON det.id_venta = v.id_venta
LEFT JOIN (
    SELECT id_venta, SUM(monto) AS monto_pagado
    FROM pago
    GROUP BY id_venta
) AS pag ON pag.id_venta = v.id_venta
WHERE ev.nombre_estado_venta = 'REGISTRADA';
GO
