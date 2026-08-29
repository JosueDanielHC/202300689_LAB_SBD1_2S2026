-- =============================================================================
-- Practica 2 - Adaptacion del DDL de Practica 1 al Dataset_Practica2.xlsx
-- -----------------------------------------------------------------------------
-- Estudiante : Josue Daniel Herrera Cottom
-- Carne      : 202300689
-- -----------------------------------------------------------------------------
-- El enunciado de P2 exige poblar el modelo de P1 con el Excel oficial.
-- El Excel NO cabe en el DDL original: aparecen catálogos 3FN, cambia
-- el nombre de varias tablas/columnas y ESTUDIANTE ahora tiene
-- es_repitencia, id_municipio e id_instituto.
-- La rubrica 2.1 penaliza si "no se adapto a los registros".
-- Este script REEMPLAZA el esquema de P1. Ejecutarlo ANTES de importar.
-- =============================================================================

DROP TABLE DETALLE_EVALUACION    CASCADE CONSTRAINTS;
DROP TABLE BITACORA              CASCADE CONSTRAINTS;
DROP TABLE EVALUACION            CASCADE CONSTRAINTS;
DROP TABLE COLOCACION            CASCADE CONSTRAINTS;
DROP TABLE PLAZA                 CASCADE CONSTRAINTS;
DROP TABLE CONTACTO_EMPRESARIAL  CASCADE CONSTRAINTS;
DROP TABLE CATEDRATICO           CASCADE CONSTRAINTS;
DROP TABLE ESTUDIANTE            CASCADE CONSTRAINTS;
DROP TABLE EMPRESA               CASCADE CONSTRAINTS;
DROP TABLE MUNICIPIO             CASCADE CONSTRAINTS;
DROP TABLE CRITERIO              CASCADE CONSTRAINTS;
DROP TABLE INSTITUTO             CASCADE CONSTRAINTS;
DROP TABLE TIPO_EVALUACION       CASCADE CONSTRAINTS;
DROP TABLE ESTADO_COLOCACION     CASCADE CONSTRAINTS;
DROP TABLE DEPARTAMENTO          CASCADE CONSTRAINTS;
DROP TABLE SECTOR_ECONOMICO      CASCADE CONSTRAINTS;

-- Tablas de P1 que ya no existen con esos nombres (por si el esquema viejo sigue ahi)
DROP TABLE PLAZA_PRACTICA            CASCADE CONSTRAINTS;
DROP TABLE CATEDRATICO_SUPERVISOR    CASCADE CONSTRAINTS;
DROP TABLE CRITERIO_EVALUACION       CASCADE CONSTRAINTS;
DROP TABLE INSTITUTO_TECNICO         CASCADE CONSTRAINTS;

-- -----------------------------------------------------------------------------
-- 1. Catalogos (sin FK entre si)
-- -----------------------------------------------------------------------------
CREATE TABLE SECTOR_ECONOMICO (
    id_sector   NUMBER          NOT NULL,
    nombre      VARCHAR2(80)    NOT NULL,
    CONSTRAINT pk_sector PRIMARY KEY (id_sector)
);

CREATE TABLE DEPARTAMENTO (
    id_departamento NUMBER          NOT NULL,
    nombre          VARCHAR2(80)    NOT NULL,
    CONSTRAINT pk_departamento PRIMARY KEY (id_departamento)
);

CREATE TABLE ESTADO_COLOCACION (
    id_estado   NUMBER          NOT NULL,
    nombre      VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_estado_colocacion PRIMARY KEY (id_estado)
);

CREATE TABLE TIPO_EVALUACION (
    id_tipo_evaluacion  NUMBER          NOT NULL,
    nombre              VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_tipo_evaluacion PRIMARY KEY (id_tipo_evaluacion)
);

CREATE TABLE CRITERIO (
    id_criterio NUMBER          NOT NULL,
    nombre      VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_criterio PRIMARY KEY (id_criterio)
);

CREATE TABLE INSTITUTO (
    id_instituto            NUMBER          NOT NULL,
    nombre                  VARCHAR2(150)   NOT NULL,
    direccion               VARCHAR2(250)   NOT NULL,
    codigo_autorizacion     VARCHAR2(50)    NOT NULL,
    CONSTRAINT pk_instituto PRIMARY KEY (id_instituto),
    CONSTRAINT uq_instituto_codigo UNIQUE (codigo_autorizacion)
);

-- -----------------------------------------------------------------------------
-- 2. MUNICIPIO (FK -> DEPARTAMENTO)
-- -----------------------------------------------------------------------------
CREATE TABLE MUNICIPIO (
    id_municipio        NUMBER          NOT NULL,
    nombre              VARCHAR2(80)    NOT NULL,
    id_departamento     NUMBER          NOT NULL,
    CONSTRAINT pk_municipio PRIMARY KEY (id_municipio),
    CONSTRAINT fk_municipio_depto FOREIGN KEY (id_departamento)
        REFERENCES DEPARTAMENTO (id_departamento)
);

-- -----------------------------------------------------------------------------
-- 3. EMPRESA (FK -> SECTOR_ECONOMICO)
-- -----------------------------------------------------------------------------
CREATE TABLE EMPRESA (
    id_empresa  NUMBER          NOT NULL,
    nombre      VARCHAR2(150)   NOT NULL,
    direccion   VARCHAR2(250)   NOT NULL,
    id_sector   NUMBER          NOT NULL,
    CONSTRAINT pk_empresa PRIMARY KEY (id_empresa),
    CONSTRAINT fk_empresa_sector FOREIGN KEY (id_sector)
        REFERENCES SECTOR_ECONOMICO (id_sector)
);

-- -----------------------------------------------------------------------------
-- 4. CATEDRATICO (FK -> INSTITUTO)
-- -----------------------------------------------------------------------------
CREATE TABLE CATEDRATICO (
    id_catedratico  NUMBER          NOT NULL,
    identificacion  VARCHAR2(30)    NOT NULL,
    nombre          VARCHAR2(150)   NOT NULL,
    telefono        VARCHAR2(20)    NOT NULL,
    especialidad    VARCHAR2(100)   NOT NULL,
    id_instituto    NUMBER          NOT NULL,
    CONSTRAINT pk_catedratico PRIMARY KEY (id_catedratico),
    CONSTRAINT uq_catedratico_identificacion UNIQUE (identificacion),
    CONSTRAINT fk_catedratico_instituto FOREIGN KEY (id_instituto)
        REFERENCES INSTITUTO (id_instituto)
);

-- -----------------------------------------------------------------------------
-- 5. CONTACTO_EMPRESARIAL (FK -> EMPRESA)
-- -----------------------------------------------------------------------------
CREATE TABLE CONTACTO_EMPRESARIAL (
    id_contacto NUMBER          NOT NULL,
    nombre      VARCHAR2(150)   NOT NULL,
    telefono    VARCHAR2(20)    NOT NULL,
    correo      VARCHAR2(120)   NOT NULL,
    id_empresa  NUMBER          NOT NULL,
    CONSTRAINT pk_contacto PRIMARY KEY (id_contacto),
    CONSTRAINT fk_contacto_empresa FOREIGN KEY (id_empresa)
        REFERENCES EMPRESA (id_empresa)
);

-- -----------------------------------------------------------------------------
-- 6. ESTUDIANTE (FK -> MUNICIPIO, INSTITUTO)
--     PLAZA      (FK -> EMPRESA, CONTACTO_EMPRESARIAL)
-- -----------------------------------------------------------------------------
CREATE TABLE ESTUDIANTE (
    carne               NUMBER          NOT NULL,
    nombre_completo     VARCHAR2(150)   NOT NULL,
    carrera_tecnica     VARCHAR2(100)   NOT NULL,
    direccion           VARCHAR2(250)   NOT NULL,
    telefono            VARCHAR2(20)    NOT NULL,
    fecha_nacimiento    DATE            NOT NULL,
    genero              VARCHAR2(5)     NOT NULL,
    es_repitencia       NUMBER(1)       NOT NULL,
    id_municipio        NUMBER          NOT NULL,
    id_instituto        NUMBER          NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (carne),
    CONSTRAINT ck_estudiante_repitencia CHECK (es_repitencia IN (0, 1)),
    CONSTRAINT fk_estudiante_municipio FOREIGN KEY (id_municipio)
        REFERENCES MUNICIPIO (id_municipio),
    CONSTRAINT fk_estudiante_instituto FOREIGN KEY (id_instituto)
        REFERENCES INSTITUTO (id_instituto)
);

CREATE TABLE PLAZA (
    id_plaza                NUMBER          NOT NULL,
    especialidad_tecnica    VARCHAR2(100)   NOT NULL,
    id_empresa              NUMBER          NOT NULL,
    id_contacto             NUMBER          NOT NULL,
    CONSTRAINT pk_plaza PRIMARY KEY (id_plaza),
    CONSTRAINT fk_plaza_empresa FOREIGN KEY (id_empresa)
        REFERENCES EMPRESA (id_empresa),
    CONSTRAINT fk_plaza_contacto FOREIGN KEY (id_contacto)
        REFERENCES CONTACTO_EMPRESARIAL (id_contacto)
);

-- -----------------------------------------------------------------------------
-- 7. COLOCACION
-- -----------------------------------------------------------------------------
CREATE TABLE COLOCACION (
    id_colocacion       NUMBER      NOT NULL,
    fecha_inicio        DATE        NOT NULL,
    fecha_finalizacion  DATE,
    id_estudiante       NUMBER      NOT NULL,
    id_plaza            NUMBER      NOT NULL,
    id_catedratico      NUMBER      NOT NULL,
    id_estado           NUMBER      NOT NULL,
    CONSTRAINT pk_colocacion PRIMARY KEY (id_colocacion),
    CONSTRAINT fk_colocacion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES ESTUDIANTE (carne),
    CONSTRAINT fk_colocacion_plaza FOREIGN KEY (id_plaza)
        REFERENCES PLAZA (id_plaza),
    CONSTRAINT fk_colocacion_catedratico FOREIGN KEY (id_catedratico)
        REFERENCES CATEDRATICO (id_catedratico),
    CONSTRAINT fk_colocacion_estado FOREIGN KEY (id_estado)
        REFERENCES ESTADO_COLOCACION (id_estado)
);

-- -----------------------------------------------------------------------------
-- 8. BITACORA
-- -----------------------------------------------------------------------------
CREATE TABLE BITACORA (
    id_bitacora                 NUMBER          NOT NULL,
    correlativo_mensual         NUMBER          NOT NULL,
    fecha                       DATE            NOT NULL,
    horas_trabajadas            NUMBER(5,2)     NOT NULL,
    actividades_realizadas      VARCHAR2(1000)  NOT NULL,
    observaciones               VARCHAR2(1000),
    id_colocacion               NUMBER          NOT NULL,
    id_contacto_validador       NUMBER          NOT NULL,
    CONSTRAINT pk_bitacora PRIMARY KEY (id_bitacora),
    CONSTRAINT ck_bitacora_correlativo CHECK (correlativo_mensual >= 1),
    CONSTRAINT ck_bitacora_horas CHECK (horas_trabajadas > 0),
    CONSTRAINT fk_bitacora_colocacion FOREIGN KEY (id_colocacion)
        REFERENCES COLOCACION (id_colocacion),
    CONSTRAINT fk_bitacora_contacto FOREIGN KEY (id_contacto_validador)
        REFERENCES CONTACTO_EMPRESARIAL (id_contacto)
);

-- -----------------------------------------------------------------------------
-- 9. EVALUACION
-- -----------------------------------------------------------------------------
CREATE TABLE EVALUACION (
    id_evaluacion       NUMBER      NOT NULL,
    fecha_evaluacion    DATE        NOT NULL,
    id_colocacion       NUMBER      NOT NULL,
    id_catedratico      NUMBER      NOT NULL,
    id_tipo_evaluacion  NUMBER      NOT NULL,
    CONSTRAINT pk_evaluacion PRIMARY KEY (id_evaluacion),
    CONSTRAINT fk_evaluacion_colocacion FOREIGN KEY (id_colocacion)
        REFERENCES COLOCACION (id_colocacion),
    CONSTRAINT fk_evaluacion_catedratico FOREIGN KEY (id_catedratico)
        REFERENCES CATEDRATICO (id_catedratico),
    CONSTRAINT fk_evaluacion_tipo FOREIGN KEY (id_tipo_evaluacion)
        REFERENCES TIPO_EVALUACION (id_tipo_evaluacion)
);

-- -----------------------------------------------------------------------------
-- 10. DETALLE_EVALUACION
-- -----------------------------------------------------------------------------
CREATE TABLE DETALLE_EVALUACION (
    id_evaluacion   NUMBER      NOT NULL,
    id_criterio     NUMBER      NOT NULL,
    puntuacion      NUMBER(1)   NOT NULL,
    CONSTRAINT pk_detalle_evaluacion PRIMARY KEY (id_evaluacion, id_criterio),
    CONSTRAINT ck_detalle_puntuacion CHECK (puntuacion IN (1, 2, 3, 4, 5)),
    CONSTRAINT fk_detalle_evaluacion FOREIGN KEY (id_evaluacion)
        REFERENCES EVALUACION (id_evaluacion),
    CONSTRAINT fk_detalle_criterio FOREIGN KEY (id_criterio)
        REFERENCES CRITERIO (id_criterio)
);
