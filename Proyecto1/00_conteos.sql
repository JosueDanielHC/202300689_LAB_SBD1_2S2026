-- =============================================================================
-- 00_conteos.sql
-- Control de carga (evidencia E08). No es entregable de la tabla del PDF.
-- Josue Daniel Herrera Cottom — 202300689
-- Esperado vs Excel: pais 3, departamento 32, municipio 80, tipo_tienda 4,
-- tipo_identificacion 3, cargo 4, categoria 10, marca 15, estado_venta 3,
-- metodo_pago 4, persona 388, tienda 20, empleado 88, cliente 300,
-- producto 114, catalogo_producto 1424, venta 1500, detalle_venta 3687,
-- pago 1389.
-- =============================================================================

SET DEFINE OFF

SELECT 'pais' t, COUNT(*) n FROM pais UNION ALL
SELECT 'departamento', COUNT(*) FROM departamento UNION ALL
SELECT 'municipio', COUNT(*) FROM municipio UNION ALL
SELECT 'tipo_tienda', COUNT(*) FROM tipo_tienda UNION ALL
SELECT 'tipo_identificacion', COUNT(*) FROM tipo_identificacion UNION ALL
SELECT 'cargo', COUNT(*) FROM cargo UNION ALL
SELECT 'categoria', COUNT(*) FROM categoria UNION ALL
SELECT 'marca', COUNT(*) FROM marca UNION ALL
SELECT 'estado_venta', COUNT(*) FROM estado_venta UNION ALL
SELECT 'metodo_pago', COUNT(*) FROM metodo_pago UNION ALL
SELECT 'persona', COUNT(*) FROM persona UNION ALL
SELECT 'tienda', COUNT(*) FROM tienda UNION ALL
SELECT 'empleado', COUNT(*) FROM empleado UNION ALL
SELECT 'cliente', COUNT(*) FROM cliente UNION ALL
SELECT 'producto', COUNT(*) FROM producto UNION ALL
SELECT 'catalogo_producto', COUNT(*) FROM catalogo_producto UNION ALL
SELECT 'venta', COUNT(*) FROM venta UNION ALL
SELECT 'detalle_venta', COUNT(*) FROM detalle_venta UNION ALL
SELECT 'pago', COUNT(*) FROM pago;

SELECT table_name
FROM user_tables
WHERE table_name IN (
  'PAIS','DEPARTAMENTO','MUNICIPIO','TIPO_TIENDA','TIPO_IDENTIFICACION',
  'CARGO','CATEGORIA','MARCA','ESTADO_VENTA','METODO_PAGO','PERSONA',
  'TIENDA','EMPLEADO','CLIENTE','PRODUCTO','CATALOGO_PRODUCTO','VENTA',
  'DETALLE_VENTA','PAGO'
)
ORDER BY table_name;
