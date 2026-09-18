-- =============================================================================
-- 04_Consulta3.sql
-- Productos más vendidos
-- Josue Daniel Herrera Cottom — 202300689
--
-- Unidades y monto desde detalle histórico. ANULADA fuera.
-- No se usa catalogo_producto.
-- =============================================================================

SET DEFINE OFF

SELECT
    pr.id_producto                          AS codigo,
    pr.nombre_producto                      AS producto,
    c.nombre_categoria                      AS categoria,
    m.nombre_marca                          AS marca,
    SUM(dv.cantidad)                        AS unidades_vendidas,
    SUM(dv.subtotal)                        AS monto_generado
FROM detalle_venta dv
JOIN producto pr        ON pr.id_producto = dv.id_producto
JOIN categoria c        ON c.id_categoria = pr.id_categoria
JOIN marca m            ON m.id_marca = pr.id_marca
JOIN venta v            ON v.id_venta = dv.id_venta
JOIN estado_venta ev    ON ev.id_estado_venta = v.id_estado_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY
    pr.id_producto,
    pr.nombre_producto,
    c.nombre_categoria,
    m.nombre_marca
ORDER BY unidades_vendidas DESC, monto_generado DESC, pr.id_producto;
