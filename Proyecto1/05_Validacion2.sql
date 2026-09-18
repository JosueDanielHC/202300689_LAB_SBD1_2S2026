-- =============================================================================
-- 05_Validacion2.sql
-- RN-39: en ventas PAGADA, SUM(pagos) = SUM(detalles)
-- Josue Daniel Herrera Cottom — 202300689
--
-- Objetivo: listar violaciones de RN-39.
-- Interpretación: 0 filas = integridad cumplida.
-- Si hay filas, esa venta está PAGADA pero el dinero no cuadra con el detalle.
--
-- Detalle y pago se agregan POR SEPARADO (subconsultas) y luego se unen.
-- Un JOIN crudo detalle × pago duplicaría montos y marcaría falsas violaciones.
-- NVL(sum_pagos, 0): una PAGADA sin pagos también es violación.
-- REGISTRADA con pago parcial NO debe salir: el filtro es solo PAGADA.
-- =============================================================================

SET DEFINE OFF

SELECT
    v.id_venta,
    ev.nombre_estado_venta,
    d.total_detalle,
    NVL(pg.total_pago, 0)                   AS total_pago,
    d.total_detalle - NVL(pg.total_pago, 0) AS diferencia
FROM venta v
JOIN estado_venta ev ON ev.id_estado_venta = v.id_estado_venta
JOIN (
        SELECT id_venta, SUM(subtotal) AS total_detalle
        FROM detalle_venta
        GROUP BY id_venta
     ) d ON d.id_venta = v.id_venta
LEFT JOIN (
        SELECT id_venta, SUM(monto) AS total_pago
        FROM pago
        GROUP BY id_venta
     ) pg ON pg.id_venta = v.id_venta
WHERE ev.nombre_estado_venta = 'PAGADA'
  AND NVL(pg.total_pago, 0) <> d.total_detalle
ORDER BY v.id_venta;
