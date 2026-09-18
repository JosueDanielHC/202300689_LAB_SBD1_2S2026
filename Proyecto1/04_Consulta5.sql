-- =============================================================================
-- 04_Consulta5.sql
-- Clientes con mayor compra
-- Josue Daniel Herrera Cottom — 202300689
--
-- Solo ventas PAGADA (el PDF dice "ventas pagadas", no "facturado").
-- REGISTRADA (aunque tenga abonos) y ANULADA quedan fuera.
-- Municipio de residencia vive en persona, no se duplica en cliente.
-- id_cliente va en la salida porque hay homónimos; agrupar solo por nombre mezclaría clientes.
-- =============================================================================

SET DEFINE OFF

SELECT
    cl.id_cliente,
    pe.nombres || ' ' || pe.apellidos       AS cliente,
    m.nombre_municipio                      AS municipio_residencia,
    COUNT(DISTINCT v.id_venta)              AS cantidad_ventas_pagadas,
    SUM(dv.subtotal)                        AS monto_total_comprado
FROM cliente cl
JOIN persona pe         ON pe.id_persona = cl.id_persona
JOIN municipio m        ON m.id_municipio = pe.id_municipio
JOIN venta v            ON v.id_cliente = cl.id_cliente
JOIN estado_venta ev    ON ev.id_estado_venta = v.id_estado_venta
JOIN detalle_venta dv   ON dv.id_venta = v.id_venta
WHERE ev.nombre_estado_venta = 'PAGADA'
GROUP BY
    cl.id_cliente,
    pe.nombres,
    pe.apellidos,
    m.nombre_municipio
ORDER BY monto_total_comprado DESC, cl.id_cliente;
