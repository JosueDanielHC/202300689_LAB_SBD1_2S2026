-- =============================================================================
-- 04_Consulta6.sql
-- Facturación por categoría y marca
-- Josue Daniel Herrera Cottom — 202300689
--
-- "Facturado" = no ANULADA (igual que consulta 1). REGISTRADA entra.
-- No se usa catalogo_producto: el precio vigente no es facturación histórica.
-- Un producto tiene 1 categoría y 1 marca: el JOIN no duplica.
-- =============================================================================

SET DEFINE OFF

SELECT
    c.nombre_categoria                      AS categoria,
    m.nombre_marca                          AS marca,
    SUM(dv.cantidad)                        AS unidades_vendidas,
    SUM(dv.subtotal)                        AS total_facturado
FROM detalle_venta dv
JOIN producto pr        ON pr.id_producto = dv.id_producto
JOIN categoria c        ON c.id_categoria = pr.id_categoria
JOIN marca m            ON m.id_marca = pr.id_marca
JOIN venta v            ON v.id_venta = dv.id_venta
JOIN estado_venta ev    ON ev.id_estado_venta = v.id_estado_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY
    c.nombre_categoria,
    m.nombre_marca
ORDER BY total_facturado DESC, c.nombre_categoria, m.nombre_marca;
