-- =============================================================================
-- 04_Consulta2.sql
-- Ventas por tipo de tienda
-- Josue Daniel Herrera Cottom — 202300689
--
-- cantidad_tiendas: TODAS las tiendas del tipo (red), no solo las que vendieron.
-- cantidad_ventas y monto_facturado: excluyen ANULADA (misma lectura de
-- "facturado" que consulta 1). REGISTRADA entra.
-- =============================================================================

SET DEFINE OFF

SELECT
    tt.nombre_tipo_tienda                   AS tipo_tienda,
    COUNT(DISTINCT t.id_tienda)             AS cantidad_tiendas,
    COUNT(DISTINCT CASE
            WHEN ev.nombre_estado_venta <> 'ANULADA'
            THEN v.id_venta
         END)                               AS cantidad_ventas,
    NVL(SUM(CASE
            WHEN ev.nombre_estado_venta <> 'ANULADA'
            THEN dv.subtotal
         END), 0)                           AS monto_facturado
FROM tipo_tienda tt
JOIN tienda t               ON t.id_tipo_tienda = tt.id_tipo_tienda
LEFT JOIN venta v           ON v.id_tienda = t.id_tienda
LEFT JOIN estado_venta ev   ON ev.id_estado_venta = v.id_estado_venta
LEFT JOIN detalle_venta dv  ON dv.id_venta = v.id_venta
GROUP BY tt.nombre_tipo_tienda
ORDER BY monto_facturado DESC, tt.nombre_tipo_tienda;
