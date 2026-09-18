-- =============================================================================
-- 04_Consulta4.sql
-- Desempeño de empleados
-- Josue Daniel Herrera Cottom — 202300689
--
-- ANULADA fuera (RN desempeño p.7). REGISTRADA sí es venta atendida.
-- COUNT(DISTINCT id_venta) por el JOIN al detalle.
-- id_empleado en la salida evita mezclar homónimos.
-- =============================================================================

SET DEFINE OFF

SELECT
    e.id_empleado,
    pe.nombres || ' ' || pe.apellidos       AS empleado,
    c.nombre_cargo                          AS cargo,
    t.nombre_tienda                         AS tienda,
    COUNT(DISTINCT v.id_venta)              AS cantidad_ventas_atendidas,
    SUM(dv.subtotal)                        AS total_facturado
FROM empleado e
JOIN persona pe         ON pe.id_persona = e.id_persona
JOIN cargo c            ON c.id_cargo = e.id_cargo
JOIN tienda t           ON t.id_tienda = e.id_tienda
JOIN venta v            ON v.id_empleado = e.id_empleado
JOIN estado_venta ev    ON ev.id_estado_venta = v.id_estado_venta
JOIN detalle_venta dv   ON dv.id_venta = v.id_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY
    e.id_empleado,
    pe.nombres,
    pe.apellidos,
    c.nombre_cargo,
    t.nombre_tienda
ORDER BY total_facturado DESC, e.id_empleado;
