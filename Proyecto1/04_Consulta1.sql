-- =============================================================================
-- 04_Consulta1.sql
-- Ventas por tienda y ubicación
-- Josue Daniel Herrera Cottom — 202300689
--
-- Total de venta = SUM(detalle.subtotal) = SUM(cantidad * precio_unitario).
-- No se usa catalogo_producto.precio_vigente.
-- ANULADA fuera (PDF: excluir anuladas). REGISTRADA y PAGADA sí entran.
-- COUNT(DISTINCT id_venta) porque el JOIN al detalle multiplica filas.
-- =============================================================================

SET DEFINE OFF

SELECT
    t.nombre_tienda                         AS tienda,
    m.nombre_municipio                      AS municipio,
    d.nombre_departamento                   AS departamento,
    p.nombre_pais                           AS pais,
    COUNT(DISTINCT v.id_venta)              AS cantidad_ventas,
    SUM(dv.subtotal)                        AS total_facturado
FROM tienda t
JOIN municipio m        ON m.id_municipio = t.id_municipio
JOIN departamento d     ON d.id_departamento = m.id_departamento
JOIN pais p             ON p.id_pais = d.id_pais
JOIN venta v            ON v.id_tienda = t.id_tienda
JOIN estado_venta ev    ON ev.id_estado_venta = v.id_estado_venta
JOIN detalle_venta dv   ON dv.id_venta = v.id_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY
    t.nombre_tienda,
    m.nombre_municipio,
    d.nombre_departamento,
    p.nombre_pais
ORDER BY total_facturado DESC, t.nombre_tienda;
