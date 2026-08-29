-- =============================================================================
-- Practica 1 - Datos de prueba (INSERT)
-- Ejecutar DESPUES de DDL.sql
-- Orden respetando dependencias FK
-- =============================================================================

-- EMPRESA (3)
INSERT INTO EMPRESA (id_empresa, nombre, direccion, sector_economico)
VALUES (1, 'TechNova Guatemala', 'Calzada Roosevelt 15-45 Zona 11, Guatemala', 'Tecnología');

INSERT INTO EMPRESA (id_empresa, nombre, direccion, sector_economico)
VALUES (2, 'Industrias del Sur S.A.', 'Km 16.5 Carretera a El Salvador, Fraijanes', 'Industria');

INSERT INTO EMPRESA (id_empresa, nombre, direccion, sector_economico)
VALUES (3, 'Comercial La Estrella', '6a Avenida 9-20 Zona 1, Guatemala', 'Comercio');

-- INSTITUTO_TECNICO (2)
INSERT INTO INSTITUTO_TECNICO (id_instituto, nombre, direccion, codigo_autorizacion)
VALUES (1, 'Instituto Tecnico Industrial INTECAP', '7a Calle 6-51 Zona 9, Guatemala', 'MINEDUC-IT-001');

INSERT INTO INSTITUTO_TECNICO (id_instituto, nombre, direccion, codigo_autorizacion)
VALUES (2, 'Instituto Tecnico Mecatronica Central', 'Avenida Petapa 32-21 Zona 12, Guatemala', 'MINEDUC-IT-002');

-- ESTUDIANTE (3)
INSERT INTO ESTUDIANTE (
    carne, nombre_completo, carrera_tecnica, direccion, telefono,
    fecha_nacimiento, genero, departamento, municipio_residencia,
    primera_practica_repitencia
) VALUES (
    '202300101', 'Ana Lucia Perez Morales', 'Electronica Industrial',
    '12 Calle 4-20 Zona 7, Guatemala', '5555-1001',
    DATE '2004-03-15', 'Femenino', 'Guatemala', 'Guatemala',
    'Primera'
);

INSERT INTO ESTUDIANTE (
    carne, nombre_completo, carrera_tecnica, direccion, telefono,
    fecha_nacimiento, genero, departamento, municipio_residencia,
    primera_practica_repitencia
) VALUES (
    '202300202', 'Carlos Eduardo Lopez Diaz', 'Mecanica Automotriz',
    '5a Avenida 8-10 Zona 2, Mixco', '5555-1002',
    DATE '2003-11-02', 'Masculino', 'Guatemala', 'Mixco',
    'Repitencia'
);

INSERT INTO ESTUDIANTE (
    carne, nombre_completo, carrera_tecnica, direccion, telefono,
    fecha_nacimiento, genero, departamento, municipio_residencia,
    primera_practica_repitencia
) VALUES (
    '202300303', 'Maria Fernanda Castillo Ruiz', 'Sistemas Informaticos',
    'Barrio El Centro, Coban', '5555-1003',
    DATE '2004-07-21', 'Femenino', 'Alta Verapaz', 'Coban',
    'Primera'
);

-- CRITERIO_EVALUACION (3) - ejemplos del enunciado
INSERT INTO CRITERIO_EVALUACION (id_criterio, nombre_criterio)
VALUES (1, 'Puntualidad');

INSERT INTO CRITERIO_EVALUACION (id_criterio, nombre_criterio)
VALUES (2, 'Calidad de trabajo');

INSERT INTO CRITERIO_EVALUACION (id_criterio, nombre_criterio)
VALUES (3, 'Actitud');

-- CONTACTO_EMPRESARIAL (3)
INSERT INTO CONTACTO_EMPRESARIAL (id_contacto, id_empresa, nombre, telefono, correo)
VALUES (1, 1, 'Juan Pablo Ramirez', '2222-3001', 'jramirez@technova.gt');

INSERT INTO CONTACTO_EMPRESARIAL (id_contacto, id_empresa, nombre, telefono, correo)
VALUES (2, 2, 'Sofia Elena Mendoza', '2222-3002', 'smendoza@industriasdelsur.gt');

INSERT INTO CONTACTO_EMPRESARIAL (id_contacto, id_empresa, nombre, telefono, correo)
VALUES (3, 3, 'Luis Alberto Gomez', '2222-3003', 'lgomez@laestrella.gt');

-- CATEDRATICO_SUPERVISOR (3)
INSERT INTO CATEDRATICO_SUPERVISOR (
    id_catedratico, id_instituto, nombre, identificacion, telefono, especialidad_que_supervisa
) VALUES (
    1, 1, 'Ing. Roberto Mejia', 'DPI-1001001000101', '4444-2001', 'Electronica Industrial'
);

INSERT INTO CATEDRATICO_SUPERVISOR (
    id_catedratico, id_instituto, nombre, identificacion, telefono, especialidad_que_supervisa
) VALUES (
    2, 1, 'Ing. Patricia Soto', 'DPI-2002002000202', '4444-2002', 'Mecanica Automotriz'
);

INSERT INTO CATEDRATICO_SUPERVISOR (
    id_catedratico, id_instituto, nombre, identificacion, telefono, especialidad_que_supervisa
) VALUES (
    3, 2, 'Ing. Diego Herrera', 'DPI-3003003000303', '4444-2003', 'Sistemas Informaticos'
);

-- PLAZA_PRACTICA (3)
INSERT INTO PLAZA_PRACTICA (id_plaza, id_empresa, id_contacto, especialidad_tecnica)
VALUES (1, 1, 1, 'Sistemas Informaticos');

INSERT INTO PLAZA_PRACTICA (id_plaza, id_empresa, id_contacto, especialidad_tecnica)
VALUES (2, 2, 2, 'Electronica Industrial');

INSERT INTO PLAZA_PRACTICA (id_plaza, id_empresa, id_contacto, especialidad_tecnica)
VALUES (3, 3, 3, 'Mecanica Automotriz');

-- COLOCACION (3)
-- Estudiante 202300101: Activa
INSERT INTO COLOCACION (
    id_colocacion, carne, id_plaza, id_catedratico, fecha_inicio, fecha_finalizacion, estado
) VALUES (
    1, '202300101', 2, 1, DATE '2026-02-01', DATE '2026-07-31', 'Activa'
);

-- Estudiante 202300202: Finalizada (historica / repitencia)
INSERT INTO COLOCACION (
    id_colocacion, carne, id_plaza, id_catedratico, fecha_inicio, fecha_finalizacion, estado
) VALUES (
    2, '202300202', 3, 2, DATE '2025-08-01', DATE '2026-01-31', 'Finalizada'
);

-- Estudiante 202300303: Activa en otra empresa
INSERT INTO COLOCACION (
    id_colocacion, carne, id_plaza, id_catedratico, fecha_inicio, fecha_finalizacion, estado
) VALUES (
    3, '202300303', 1, 3, DATE '2026-03-01', NULL, 'Activa'
);

-- BITACORA (3) - correlativos del mismo mes para colocacion 1
INSERT INTO BITACORA (
    id_bitacora, id_colocacion, id_contacto, correlativo, fecha,
    horas_trabajadas, actividades_realizadas, observaciones
) VALUES (
    1, 1, 2, 1, DATE '2026-02-03',
    8.00, 'Induccion y revision de planos electricos', 'Primer dia de practica'
);

INSERT INTO BITACORA (
    id_bitacora, id_colocacion, id_contacto, correlativo, fecha,
    horas_trabajadas, actividades_realizadas, observaciones
) VALUES (
    2, 1, 2, 2, DATE '2026-02-04',
    7.50, 'Apoyo en ensamble de tableros de control', NULL
);

INSERT INTO BITACORA (
    id_bitacora, id_colocacion, id_contacto, correlativo, fecha,
    horas_trabajadas, actividades_realizadas, observaciones
) VALUES (
    3, 3, 1, 1, DATE '2026-03-02',
    8.00, 'Configuracion de entorno de desarrollo', 'Validado por contacto de plaza'
);

-- EVALUACION (3)
-- Colocacion 1: Parcial; Colocacion 2: Parcial y Final (ya finalizada)
INSERT INTO EVALUACION (id_evaluacion, id_colocacion, id_catedratico, tipo)
VALUES (1, 1, 1, 'Parcial');

INSERT INTO EVALUACION (id_evaluacion, id_colocacion, id_catedratico, tipo)
VALUES (2, 2, 2, 'Parcial');

INSERT INTO EVALUACION (id_evaluacion, id_colocacion, id_catedratico, tipo)
VALUES (3, 2, 2, 'Final');

-- DETALLE_EVALUACION (varios puntajes 1-5)
INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (1, 1, 5);
INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (1, 2, 4);
INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (1, 3, 5);

INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (2, 1, 4);
INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (2, 2, 3);
INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (2, 3, 4);

INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (3, 1, 5);
INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (3, 2, 5);
INSERT INTO DETALLE_EVALUACION (id_evaluacion, id_criterio, puntuacion) VALUES (3, 3, 4);

COMMIT;