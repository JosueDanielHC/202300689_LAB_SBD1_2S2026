-- =============================================================================
-- 05_Validacion1.sql
-- RN-31: el empleado de la venta pertenece a la misma tienda de la venta
-- Josue Daniel Herrera Cottom — 202300689
--
-- Objetivo: listar violaciones de RN-31.
-- Interpretación: 0 filas = integridad cumplida.
-- Si hay filas, cada una es una venta cuyo empleado no trabaja en esa tienda.
-- No es declarable con PK/FK/CHECK (haría falta trigger o duplicar id_tienda).
-- =============================================================================

SET DEFINE OFF

SELECT
    v.id_venta,
    v.id_tienda                             AS tienda_de_la_venta,
    e.id_tienda                             AS tienda_del_empleado,
    e.id_empleado
FROM venta v
JOIN empleado e ON e.id_empleado = v.id_empleado
WHERE v.id_tienda <> e.id_tienda
ORDER BY v.id_venta;
