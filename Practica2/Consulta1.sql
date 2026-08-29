-- =============================================================================
-- Practica 2 - Bases de Datos 1
-- Consulta 1: Directorio de estudiantes activos
-- -----------------------------------------------------------------------------
-- Estudiante : Josue Daniel Herrera Cottom
-- Carne      : 202300689
-- Motor      : Oracle Database
-- Dataset    : Dataset_Practica2.xlsx
-- -----------------------------------------------------------------------------
-- Carné, nombre completo, empresa y especialidad de la plaza.
-- Solo colocaciones con ESTADO_COLOCACION.nombre = 'Activa'.
-- =============================================================================

SELECT
    e.carne                     AS carne,
    e.nombre_completo           AS nombre_estudiante,
    em.nombre                   AS nombre_empresa,
    p.especialidad_tecnica      AS especialidad_plaza
FROM ESTUDIANTE e
INNER JOIN COLOCACION c
    ON e.carne = c.id_estudiante
INNER JOIN ESTADO_COLOCACION ec
    ON c.id_estado = ec.id_estado
INNER JOIN PLAZA p
    ON c.id_plaza = p.id_plaza
INNER JOIN EMPRESA em
    ON p.id_empresa = em.id_empresa
WHERE ec.nombre = 'Activa'
ORDER BY e.carne;
