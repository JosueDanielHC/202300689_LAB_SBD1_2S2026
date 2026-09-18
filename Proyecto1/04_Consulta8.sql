-- =============================================================================
-- 04_Consulta8.sql
-- Ventas pendientes de pago (estado REGISTRADA)
-- Josue Daniel Herrera Cottom — 202300689
--
-- Detalle y pago se agregan POR SEPARADO y luego se unen a venta.
-- Prohibido JOIN crudo detalle × pago (producto cartesiano por venta).
-- total_venta = SUM(subtotal); total_pagado = NVL(SUM(monto), 0).
-- Se incluye id_venta y fecha_venta para que la fila sea interpretable.
-- =============================================================================

SET DEFINE OFF

SELECT
    v.id_venta,
    v.fecha_venta,
    d.total_venta,
    NVL(pg.total_pagado, 0)                 AS total_pagado,
    d.total_venta - NVL(pg.total_pagado, 0) AS diferencia_pendiente
FROM venta v
JOIN estado_venta ev ON ev.id_estado_venta = v.id_estado_venta
JOIN (
        SELECT id_venta, SUM(subtotal) AS total_venta
        FROM detalle_venta
        GROUP BY id_venta
     ) d ON d.id_venta = v.id_venta
LEFT JOIN (
        SELECT id_venta, SUM(monto) AS total_pagado
        FROM pago
        GROUP BY id_venta
     ) pg ON pg.id_venta = v.id_venta
WHERE ev.nombre_estado_venta = 'REGISTRADA'
ORDER BY diferencia_pendiente DESC, v.id_venta;
