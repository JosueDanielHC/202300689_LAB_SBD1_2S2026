-- =============================================================================
-- 04_Consulta7.sql
-- Uso de métodos de pago
-- Josue Daniel Herrera Cottom — 202300689
--
-- Métrica = dinero RECIBIDO (pago.monto), no facturado.
-- Solo tablas pago y metodo_pago. Sin filtro de estado.
-- No se une a detalle_venta: eso multiplicaría cada pago por cada línea.
-- Los 117 abonos de ventas REGISTRADA sí cuentan.
-- =============================================================================

SET DEFINE OFF

SELECT
    mp.nombre_metodo_pago                   AS metodo_pago,
    COUNT(p.id_pago)                        AS cantidad_pagos,
    SUM(p.monto)                            AS monto_total_recibido
FROM pago p
JOIN metodo_pago mp ON mp.id_metodo_pago = p.id_metodo_pago
GROUP BY mp.nombre_metodo_pago
ORDER BY monto_total_recibido DESC, mp.nombre_metodo_pago;
