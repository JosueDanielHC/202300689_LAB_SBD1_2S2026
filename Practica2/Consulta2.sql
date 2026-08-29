-- =============================================================================
-- Practica 2 - Bases de Datos 1
-- Consulta 2: Oferta de plazas por empresa
-- -----------------------------------------------------------------------------
-- Estudiante : Josue Daniel Herrera Cottom
-- Carne      : 202300689
-- Motor      : Oracle Database
-- Dataset    : Dataset_Practica2.xlsx
-- -----------------------------------------------------------------------------
-- Nombre de cada empresa y COUNT de plazas. Orden descendente por cantidad.
-- =============================================================================

SELECT
    em.nombre               AS nombre_empresa,
    COUNT(p.id_plaza)       AS total_plazas
FROM EMPRESA em
INNER JOIN PLAZA p
    ON em.id_empresa = p.id_empresa
GROUP BY
    em.id_empresa,
    em.nombre
ORDER BY
    total_plazas DESC,
    em.nombre;
