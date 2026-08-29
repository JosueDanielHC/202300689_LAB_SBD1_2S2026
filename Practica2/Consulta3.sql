-- =============================================================================
-- Practica 2 - Bases de Datos 1
-- Consulta 3: Carga de validacion por contacto empresarial
-- -----------------------------------------------------------------------------
-- Estudiante : Josue Daniel Herrera Cottom
-- Carne      : 202300689
-- Motor      : Oracle Database
-- Dataset    : Dataset_Practica2.xlsx
-- -----------------------------------------------------------------------------
-- Contacto, empresa y SUM de horas validadas en bitacoras
-- del 1 de julio de 2026 al 31 de agosto de 2026.
-- =============================================================================

SELECT
    ce.nombre                       AS nombre_contacto,
    em.nombre                       AS nombre_empresa,
    SUM(b.horas_trabajadas)         AS total_horas_validadas
FROM BITACORA b
INNER JOIN CONTACTO_EMPRESARIAL ce
    ON b.id_contacto_validador = ce.id_contacto
INNER JOIN EMPRESA em
    ON ce.id_empresa = em.id_empresa
WHERE b.fecha BETWEEN DATE '2026-07-01' AND DATE '2026-08-31'
GROUP BY
    ce.id_contacto,
    ce.nombre,
    em.nombre
ORDER BY
    total_horas_validadas DESC,
    ce.nombre;
