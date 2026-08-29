-- =============================================================================
-- Practica 1 - Bases de Datos 1
-- Sistema de Gestion de EPS de Institutos Tecnicos
-- -----------------------------------------------------------------------------
-- Estudiante : Josue Daniel Herrera Cottom
-- Carne      : 202300689
-- Entrega    : [BD1]_Practica1_202300689.zip
-- =============================================================================

-- SUPUESTOS DE DISENO (no son datos del enunciado):
--   * Identificadores tecnicos id_* donde no hay clave natural clara.
--   * UNIQUE (id_colocacion, tipo) en EVALUACION: como maximo una Parcial
--     y una Final por colocacion.
--   * FK id_contacto en BITACORA representa la validacion por el contacto
--     empresarial correspondiente.
--   * El correlativo de BITACORA reinicia cada mes; la unicidad logica es
--     (id_colocacion, anio-mes(fecha), correlativo). El mes se DERIVA de
--     fecha; NO se almacenan columnas mes/anio.
--   * Departamento y municipio se mantienen en ESTUDIANTE (opcion B).
-- =============================================================================
-- -----------------------------------------------------------------------------
-- ELIMINACION (orden inverso de dependencias)
-- -----------------------------------------------------------------------------
DROP TABLE DETALLE_EVALUACION CASCADE CONSTRAINTS;
DROP TABLE BITACORA CASCADE CONSTRAINTS;
DROP TABLE EVALUACION CASCADE CONSTRAINTS;
DROP TABLE COLOCACION CASCADE CONSTRAINTS;
DROP TABLE PLAZA_PRACTICA CASCADE CONSTRAINTS;
DROP TABLE CONTACTO_EMPRESARIAL CASCADE CONSTRAINTS;
DROP TABLE CATEDRATICO_SUPERVISOR CASCADE CONSTRAINTS;
DROP TABLE CRITERIO_EVALUACION CASCADE CONSTRAINTS;
DROP TABLE ESTUDIANTE CASCADE CONSTRAINTS;
DROP TABLE INSTITUTO_TECNICO CASCADE CONSTRAINTS;
DROP TABLE EMPRESA CASCADE CONSTRAINTS;

-- -----------------------------------------------------------------------------
-- EMPRESA
-- -----------------------------------------------------------------------------
CREATE TABLE EMPRESA (
    id_empresa          NUMBER          NOT NULL,
    nombre              VARCHAR2(150)   NOT NULL,
    direccion           VARCHAR2(250)   NOT NULL,
    sector_economico    VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_empresa PRIMARY KEY (id_empresa),
    CONSTRAINT ck_empresa_sector CHECK (
        sector_economico IN ('Industria', 'Servicios', 'Comercio', 'Tecnología')
    )
);

-- -----------------------------------------------------------------------------
-- INSTITUTO_TECNICO
-- -----------------------------------------------------------------------------
CREATE TABLE INSTITUTO_TECNICO (
    id_instituto            NUMBER          NOT NULL,
    nombre                  VARCHAR2(150)   NOT NULL,
    direccion               VARCHAR2(250)   NOT NULL,
    codigo_autorizacion     VARCHAR2(50)    NOT NULL,
    CONSTRAINT pk_instituto PRIMARY KEY (id_instituto),
    CONSTRAINT uq_instituto_codigo UNIQUE (codigo_autorizacion)
);

-- -----------------------------------------------------------------------------
-- ESTUDIANTE
-- PK natural: carne (del enunciado)
-- SUPUESTO opcion B: departamento y municipio_residencia en esta tabla
-- -----------------------------------------------------------------------------
CREATE TABLE ESTUDIANTE (
    carne                       VARCHAR2(20)    NOT NULL,
    nombre_completo             VARCHAR2(150)   NOT NULL,
    carrera_tecnica             VARCHAR2(100)   NOT NULL,
    direccion                   VARCHAR2(250)   NOT NULL,
    telefono                    VARCHAR2(20)    NOT NULL,
    fecha_nacimiento            DATE            NOT NULL,
    genero                      VARCHAR2(20)    NOT NULL,
    departamento                VARCHAR2(80)    NOT NULL,
    municipio_residencia        VARCHAR2(80)    NOT NULL,
    primera_practica_repitencia VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (carne)
);

-- -----------------------------------------------------------------------------
-- CRITERIO_EVALUACION
-- -----------------------------------------------------------------------------
CREATE TABLE CRITERIO_EVALUACION (
    id_criterio         NUMBER          NOT NULL,
    nombre_criterio     VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_criterio PRIMARY KEY (id_criterio),
    CONSTRAINT uq_criterio_nombre UNIQUE (nombre_criterio)
);

-- -----------------------------------------------------------------------------
-- CONTACTO_EMPRESARIAL
-- -----------------------------------------------------------------------------
CREATE TABLE CONTACTO_EMPRESARIAL (
    id_contacto     NUMBER          NOT NULL,
    id_empresa      NUMBER          NOT NULL,
    nombre          VARCHAR2(150)   NOT NULL,
    telefono        VARCHAR2(20)    NOT NULL,
    correo          VARCHAR2(120)   NOT NULL,
    CONSTRAINT pk_contacto PRIMARY KEY (id_contacto),
    CONSTRAINT fk_contacto_empresa FOREIGN KEY (id_empresa)
        REFERENCES EMPRESA (id_empresa)
);

-- -----------------------------------------------------------------------------
-- CATEDRATICO_SUPERVISOR
-- -----------------------------------------------------------------------------
CREATE TABLE CATEDRATICO_SUPERVISOR (
    id_catedratico              NUMBER          NOT NULL,
    id_instituto                NUMBER          NOT NULL,
    nombre                      VARCHAR2(150)   NOT NULL,
    identificacion              VARCHAR2(30)    NOT NULL,
    telefono                    VARCHAR2(20)    NOT NULL,
    especialidad_que_supervisa  VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_catedratico PRIMARY KEY (id_catedratico),
    CONSTRAINT uq_catedratico_identificacion UNIQUE (identificacion),
    CONSTRAINT fk_catedratico_instituto FOREIGN KEY (id_instituto)
        REFERENCES INSTITUTO_TECNICO (id_instituto)
);

-- -----------------------------------------------------------------------------
-- PLAZA_PRACTICA
-- id_contacto = contacto empresarial responsable de la plaza
-- -----------------------------------------------------------------------------
CREATE TABLE PLAZA_PRACTICA (
    id_plaza                NUMBER          NOT NULL,
    id_empresa              NUMBER          NOT NULL,
    id_contacto             NUMBER          NOT NULL,
    especialidad_tecnica    VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_plaza PRIMARY KEY (id_plaza),
    CONSTRAINT fk_plaza_empresa FOREIGN KEY (id_empresa)
        REFERENCES EMPRESA (id_empresa),
    CONSTRAINT fk_plaza_contacto FOREIGN KEY (id_contacto)
        REFERENCES CONTACTO_EMPRESARIAL (id_contacto)
);

-- -----------------------------------------------------------------------------
-- COLOCACION
-- Regla de negocio (aplicacion/logica): maximo 1 colocacion Activa por estudiante
-- -----------------------------------------------------------------------------
CREATE TABLE COLOCACION (
    id_colocacion       NUMBER          NOT NULL,
    carne               VARCHAR2(20)    NOT NULL,
    id_plaza            NUMBER          NOT NULL,
    id_catedratico      NUMBER          NOT NULL,
    fecha_inicio        DATE            NOT NULL,
    fecha_finalizacion  DATE,
    estado              VARCHAR2(15)    NOT NULL,
    CONSTRAINT pk_colocacion PRIMARY KEY (id_colocacion),
    CONSTRAINT ck_colocacion_estado CHECK (
        estado IN ('Activa', 'Finalizada', 'Cancelada')
    ),
    CONSTRAINT fk_colocacion_estudiante FOREIGN KEY (carne)
        REFERENCES ESTUDIANTE (carne),
    CONSTRAINT fk_colocacion_plaza FOREIGN KEY (id_plaza)
        REFERENCES PLAZA_PRACTICA (id_plaza),
    CONSTRAINT fk_colocacion_catedratico FOREIGN KEY (id_catedratico)
        REFERENCES CATEDRATICO_SUPERVISOR (id_catedratico)
);

-- -----------------------------------------------------------------------------
-- BITACORA
-- id_contacto = contacto que valida la entrada (relacion obligatoria del enunciado)
-- Unicidad logica del correlativo mensual: (id_colocacion, anio-mes(fecha), correlativo)
-- -----------------------------------------------------------------------------
CREATE TABLE BITACORA (
    id_bitacora             NUMBER          NOT NULL,
    id_colocacion           NUMBER          NOT NULL,
    id_contacto             NUMBER          NOT NULL,
    correlativo             NUMBER          NOT NULL,
    fecha                   DATE            NOT NULL,
    horas_trabajadas        NUMBER(5,2)     NOT NULL,
    actividades_realizadas  VARCHAR2(1000)  NOT NULL,
    observaciones           VARCHAR2(1000),
    CONSTRAINT pk_bitacora PRIMARY KEY (id_bitacora),
    CONSTRAINT ck_bitacora_correlativo CHECK (correlativo >= 1),
    CONSTRAINT ck_bitacora_horas CHECK (horas_trabajadas > 0),
    CONSTRAINT fk_bitacora_colocacion FOREIGN KEY (id_colocacion)
        REFERENCES COLOCACION (id_colocacion),
    CONSTRAINT fk_bitacora_contacto FOREIGN KEY (id_contacto)
        REFERENCES CONTACTO_EMPRESARIAL (id_contacto)
);

-- -----------------------------------------------------------------------------
-- EVALUACION
-- SUPUESTO: UNIQUE (id_colocacion, tipo) => <=1 Parcial y <=1 Final por colocacion
-- -----------------------------------------------------------------------------
CREATE TABLE EVALUACION (
    id_evaluacion   NUMBER          NOT NULL,
    id_colocacion   NUMBER          NOT NULL,
    id_catedratico  NUMBER          NOT NULL,
    tipo            VARCHAR2(10)    NOT NULL,
    CONSTRAINT pk_evaluacion PRIMARY KEY (id_evaluacion),
    CONSTRAINT ck_evaluacion_tipo CHECK (
        tipo IN ('Parcial', 'Final')
    ),
    CONSTRAINT uq_evaluacion_colocacion_tipo UNIQUE (id_colocacion, tipo),
    CONSTRAINT fk_evaluacion_colocacion FOREIGN KEY (id_colocacion)
        REFERENCES COLOCACION (id_colocacion),
    CONSTRAINT fk_evaluacion_catedratico FOREIGN KEY (id_catedratico)
        REFERENCES CATEDRATICO_SUPERVISOR (id_catedratico)
);

-- -----------------------------------------------------------------------------
-- DETALLE_EVALUACION
-- Resuelve N:M EVALUACION - CRITERIO_EVALUACION
-- DF: (id_evaluacion, id_criterio) -> puntuacion
-- -----------------------------------------------------------------------------
CREATE TABLE DETALLE_EVALUACION (
    id_evaluacion   NUMBER      NOT NULL,
    id_criterio     NUMBER      NOT NULL,
    puntuacion      NUMBER(1)   NOT NULL,
    CONSTRAINT pk_detalle_evaluacion PRIMARY KEY (id_evaluacion, id_criterio),
    CONSTRAINT ck_detalle_puntuacion CHECK (
        puntuacion IN (1, 2, 3, 4, 5)
    ),
    CONSTRAINT fk_detalle_evaluacion FOREIGN KEY (id_evaluacion)
        REFERENCES EVALUACION (id_evaluacion),
    CONSTRAINT fk_detalle_criterio FOREIGN KEY (id_criterio)
        REFERENCES CRITERIO_EVALUACION (id_criterio)
);

-- =============================================================================
-- Fin del script DDL
-- =============================================================================