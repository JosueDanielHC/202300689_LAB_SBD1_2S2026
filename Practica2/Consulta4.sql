-- =============================================================================
-- Practica 2 - Bases de Datos 1
-- Consulta 4: Estudiantes en repitencia
-- -----------------------------------------------------------------------------
-- Estudiante : Josue Daniel Herrera Cottom
-- Carne      : 202300689
-- Motor      : Oracle Database
-- Dataset    : Dataset_Practica2.xlsx
-- -----------------------------------------------------------------------------
-- es_repitencia = 1. Instituto de procedencia, contacto que valida
-- bitacoras (si no hay bitacora, se usa el contacto responsable de la plaza)
-- y estado actual de la colocacion.
-- =============================================================================

SELECT DISTINCT
    e.nombre_completo                           AS nombre_estudiante,
    i.nombre                                    AS nombre_instituto,
    NVL(ce_val.nombre, ce_plz.nombre)           AS contacto_validador,
    ec.nombre                                   AS estado_colocacion
FROM ESTUDIANTE e
INNER JOIN INSTITUTO i
    ON e.id_instituto = i.id_instituto
INNER JOIN COLOCACION c
    ON e.carne = c.id_estudiante
INNER JOIN ESTADO_COLOCACION ec
    ON c.id_estado = ec.id_estado
INNER JOIN PLAZA p
    ON c.id_plaza = p.id_plaza
INNER JOIN CONTACTO_EMPRESARIAL ce_plz
    ON p.id_contacto = ce_plz.id_contacto
LEFT JOIN BITACORA b
    ON c.id_colocacion = b.id_colocacion
LEFT JOIN CONTACTO_EMPRESARIAL ce_val
    ON b.id_contacto_validador = ce_val.id_contacto
WHERE e.es_repitencia = 1
ORDER BY
    e.nombre_completo,
    ec.nombre;
