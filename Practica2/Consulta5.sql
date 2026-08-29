-- =============================================================================
-- Practica 2 - Bases de Datos 1
-- Consulta 5: Auditoria de bitacoras sin registros (ultimo mes)
-- -----------------------------------------------------------------------------
-- Estudiante : Josue Daniel Herrera Cottom
-- Carne      : 202300689
-- Motor      : Oracle Database
-- Dataset    : Dataset_Practica2.xlsx
-- -----------------------------------------------------------------------------
-- Colocaciones Activa SIN bitacora en el ultimo mes (NOT EXISTS).
-- Se muestra el catedratico supervisor responsable.
-- =============================================================================

SELECT
    c.id_colocacion         AS id_colocacion,
    e.carne                 AS carne,
    e.nombre_completo       AS nombre_estudiante,
    cat.nombre              AS catedratico_supervisor
FROM COLOCACION c
INNER JOIN ESTADO_COLOCACION ec
    ON c.id_estado = ec.id_estado
INNER JOIN ESTUDIANTE e
    ON c.id_estudiante = e.carne
INNER JOIN CATEDRATICO cat
    ON c.id_catedratico = cat.id_catedratico
WHERE ec.nombre = 'Activa'
  AND NOT EXISTS (
        SELECT 1
        FROM BITACORA b
        WHERE b.id_colocacion = c.id_colocacion
          AND b.fecha >= ADD_MONTHS(TRUNC(SYSDATE), -1)
          AND b.fecha <  TRUNC(SYSDATE) + 1
      )
ORDER BY
    cat.nombre,
    e.carne;
