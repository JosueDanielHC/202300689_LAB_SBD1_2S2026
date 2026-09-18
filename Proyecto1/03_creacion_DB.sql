-- =============================================================================
-- 03_creacion_DB.sql
-- Comercial La Estrella — Proyecto 1 Bases de Datos 1
-- Josue Daniel Herrera Cottom — 202300689
-- Motor: Oracle Database. Equivalente al modelo relacional (MODELO_MAESTRO §17).
-- Ejecutar en un esquema vacío (o reejecutable: DROP previo).
-- Orden: padres → catálogos → personas/tienda → producto → operación.
-- =============================================================================

SET DEFINE OFF
SET ECHO ON

PROMPT === Eliminando objetos previos (si existen) ===

BEGIN
  FOR r IN (
    SELECT table_name
    FROM user_tables
    WHERE table_name IN (
      'PAGO','DETALLE_VENTA','VENTA','CATALOGO_PRODUCTO','PRODUCTO',
      'CLIENTE','EMPLEADO','TIENDA','PERSONA','METODO_PAGO','ESTADO_VENTA',
      'MARCA','CATEGORIA','CARGO','TIPO_IDENTIFICACION','TIPO_TIENDA',
      'MUNICIPIO','DEPARTAMENTO','PAIS'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

PROMPT === Creando tablas ===

CREATE TABLE pais (
  id_pais        NUMBER(10)    NOT NULL,
  nombre_pais    VARCHAR2(50)  NOT NULL,
  CONSTRAINT pk_pais PRIMARY KEY (id_pais),
  CONSTRAINT uk_pais_nombre UNIQUE (nombre_pais)
);

CREATE TABLE departamento (
  id_departamento        NUMBER(10)    NOT NULL,
  nombre_departamento    VARCHAR2(80)  NOT NULL,
  id_pais                NUMBER(10)    NOT NULL,
  CONSTRAINT pk_departamento PRIMARY KEY (id_departamento),
  CONSTRAINT uk_dep_pais_nombre UNIQUE (id_pais, nombre_departamento),
  CONSTRAINT fk_dep_pais FOREIGN KEY (id_pais) REFERENCES pais (id_pais)
);

CREATE TABLE municipio (
  id_municipio         NUMBER(10)    NOT NULL,
  nombre_municipio     VARCHAR2(80)  NOT NULL,
  id_departamento      NUMBER(10)    NOT NULL,
  CONSTRAINT pk_municipio PRIMARY KEY (id_municipio),
  CONSTRAINT uk_mun_dep_nombre UNIQUE (id_departamento, nombre_municipio),
  CONSTRAINT fk_mun_dep FOREIGN KEY (id_departamento) REFERENCES departamento (id_departamento)
);

CREATE TABLE tipo_tienda (
  id_tipo_tienda        NUMBER(10)    NOT NULL,
  nombre_tipo_tienda    VARCHAR2(50)  NOT NULL,
  CONSTRAINT pk_tipo_tienda PRIMARY KEY (id_tipo_tienda),
  CONSTRAINT uk_tipo_tienda_nom UNIQUE (nombre_tipo_tienda)
);

CREATE TABLE tipo_identificacion (
  id_tipo_identificacion        NUMBER(10)    NOT NULL,
  nombre_tipo_identificacion    VARCHAR2(50)  NOT NULL,
  CONSTRAINT pk_tipo_identificacion PRIMARY KEY (id_tipo_identificacion),
  CONSTRAINT uk_tipide_nombre UNIQUE (nombre_tipo_identificacion)
);

CREATE TABLE cargo (
  id_cargo        NUMBER(10)    NOT NULL,
  nombre_cargo    VARCHAR2(50)  NOT NULL,
  CONSTRAINT pk_cargo PRIMARY KEY (id_cargo),
  CONSTRAINT uk_cargo_nombre UNIQUE (nombre_cargo)
);

CREATE TABLE categoria (
  id_categoria        NUMBER(10)    NOT NULL,
  nombre_categoria    VARCHAR2(50)  NOT NULL,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT uk_cat_nombre UNIQUE (nombre_categoria)
);

CREATE TABLE marca (
  id_marca        NUMBER(10)    NOT NULL,
  nombre_marca    VARCHAR2(50)  NOT NULL,
  CONSTRAINT pk_marca PRIMARY KEY (id_marca),
  CONSTRAINT uk_marca_nombre UNIQUE (nombre_marca)
);

CREATE TABLE estado_venta (
  id_estado_venta        NUMBER(10)    NOT NULL,
  nombre_estado_venta    VARCHAR2(20)  NOT NULL,
  CONSTRAINT pk_estado_venta PRIMARY KEY (id_estado_venta),
  CONSTRAINT uk_estado_nombre UNIQUE (nombre_estado_venta)
);

CREATE TABLE metodo_pago (
  id_metodo_pago        NUMBER(10)    NOT NULL,
  nombre_metodo_pago    VARCHAR2(50)  NOT NULL,
  CONSTRAINT pk_metodo_pago PRIMARY KEY (id_metodo_pago),
  CONSTRAINT uk_metpag_nombre UNIQUE (nombre_metodo_pago)
);

CREATE TABLE persona (
  id_persona      NUMBER(10)     NOT NULL,
  nombres         VARCHAR2(80)   NOT NULL,
  apellidos       VARCHAR2(80)   NOT NULL,
  telefono        VARCHAR2(20)   NOT NULL,
  correo          VARCHAR2(120)  NULL,
  direccion       VARCHAR2(150)  NOT NULL,
  id_municipio    NUMBER(10)     NOT NULL,
  CONSTRAINT pk_persona PRIMARY KEY (id_persona),
  CONSTRAINT uk_persona_correo UNIQUE (correo),
  CONSTRAINT fk_persona_mun FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio)
);

CREATE TABLE tienda (
  id_tienda         NUMBER(10)     NOT NULL,
  nombre_tienda     VARCHAR2(100)  NOT NULL,
  direccion         VARCHAR2(150)  NOT NULL,
  telefono          VARCHAR2(20)   NOT NULL,
  id_municipio      NUMBER(10)     NOT NULL,
  id_tipo_tienda    NUMBER(10)     NOT NULL,
  CONSTRAINT pk_tienda PRIMARY KEY (id_tienda),
  CONSTRAINT fk_tienda_mun FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio),
  CONSTRAINT fk_tienda_tipo FOREIGN KEY (id_tipo_tienda) REFERENCES tipo_tienda (id_tipo_tienda)
);

CREATE TABLE empleado (
  id_empleado           NUMBER(10)  NOT NULL,
  fecha_contratacion    DATE        NOT NULL,
  id_tienda             NUMBER(10)  NOT NULL,
  id_cargo              NUMBER(10)  NOT NULL,
  id_persona            NUMBER(10)  NOT NULL,
  CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
  CONSTRAINT uk_emp_persona UNIQUE (id_persona),
  CONSTRAINT fk_emp_tienda FOREIGN KEY (id_tienda) REFERENCES tienda (id_tienda),
  CONSTRAINT fk_emp_cargo FOREIGN KEY (id_cargo) REFERENCES cargo (id_cargo),
  CONSTRAINT fk_emp_persona FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
);

CREATE TABLE cliente (
  id_cliente                  NUMBER(10)    NOT NULL,
  id_tipo_identificacion      NUMBER(10)    NOT NULL,
  numero_identificacion       VARCHAR2(20)  NOT NULL,
  id_persona                  NUMBER(10)    NOT NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uk_cli_persona UNIQUE (id_persona),
  CONSTRAINT uk_cli_tipo_numero UNIQUE (id_tipo_identificacion, numero_identificacion),
  CONSTRAINT fk_cli_tipide FOREIGN KEY (id_tipo_identificacion) REFERENCES tipo_identificacion (id_tipo_identificacion),
  CONSTRAINT fk_cli_persona FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
);

CREATE TABLE producto (
  id_producto         NUMBER(10)     NOT NULL,
  nombre_producto     VARCHAR2(100)  NOT NULL,
  descripcion         VARCHAR2(200)  NOT NULL,
  id_categoria        NUMBER(10)     NOT NULL,
  id_marca            NUMBER(10)     NOT NULL,
  CONSTRAINT pk_producto PRIMARY KEY (id_producto),
  CONSTRAINT fk_prod_cat FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
  CONSTRAINT fk_prod_marca FOREIGN KEY (id_marca) REFERENCES marca (id_marca)
);

CREATE TABLE catalogo_producto (
  id_tienda             NUMBER(10)     NOT NULL,
  id_producto           NUMBER(10)     NOT NULL,
  precio_vigente        NUMBER(12,2)   NOT NULL,
  existencia_actual     NUMBER(10)     NOT NULL,
  CONSTRAINT pk_catalogo_producto PRIMARY KEY (id_tienda, id_producto),
  CONSTRAINT fk_catpro_tienda FOREIGN KEY (id_tienda) REFERENCES tienda (id_tienda),
  CONSTRAINT fk_catpro_prod FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
  CONSTRAINT ck_catpro_precio CHECK (precio_vigente > 0),
  CONSTRAINT ck_catpro_exist CHECK (existencia_actual >= 0)
);

CREATE TABLE venta (
  id_venta            NUMBER(10)  NOT NULL,
  fecha_venta         DATE        NOT NULL,
  id_tienda           NUMBER(10)  NOT NULL,
  id_empleado         NUMBER(10)  NOT NULL,
  id_cliente          NUMBER(10)  NOT NULL,
  id_estado_venta     NUMBER(10)  NOT NULL,
  CONSTRAINT pk_venta PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_tienda FOREIGN KEY (id_tienda) REFERENCES tienda (id_tienda),
  CONSTRAINT fk_venta_emp FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
  CONSTRAINT fk_venta_cli FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
  CONSTRAINT fk_venta_est FOREIGN KEY (id_estado_venta) REFERENCES estado_venta (id_estado_venta)
);

CREATE TABLE detalle_venta (
  id_venta            NUMBER(10)    NOT NULL,
  id_producto         NUMBER(10)    NOT NULL,
  cantidad            NUMBER(10)    NOT NULL,
  precio_unitario     NUMBER(12,2)  NOT NULL,
  subtotal            NUMBER(12,2)  NOT NULL,
  CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),
  CONSTRAINT fk_det_venta FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
  CONSTRAINT fk_det_prod FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
  CONSTRAINT ck_det_cant CHECK (cantidad > 0),
  CONSTRAINT ck_det_precio CHECK (precio_unitario > 0),
  CONSTRAINT ck_det_subtot CHECK (subtotal = cantidad * precio_unitario)
);

CREATE TABLE pago (
  id_pago            NUMBER(10)    NOT NULL,
  monto              NUMBER(12,2)  NOT NULL,
  id_metodo_pago     NUMBER(10)    NOT NULL,
  id_venta           NUMBER(10)    NOT NULL,
  CONSTRAINT pk_pago PRIMARY KEY (id_pago),
  CONSTRAINT fk_pago_met FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago (id_metodo_pago),
  CONSTRAINT fk_pago_venta FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
  CONSTRAINT ck_pago_monto CHECK (monto > 0)
);

PROMPT === Comentarios de diccionario ===

COMMENT ON TABLE pais IS 'Pais donde opera la red comercial.';
COMMENT ON COLUMN pais.id_pais IS 'Codigo de pais (Excel ID_PA).';
COMMENT ON COLUMN pais.nombre_pais IS 'Nombre unico del pais.';

COMMENT ON TABLE departamento IS 'Division administrativa de un pais.';
COMMENT ON COLUMN departamento.id_departamento IS 'Codigo de departamento (Excel ID_DEP).';
COMMENT ON COLUMN departamento.nombre_departamento IS 'Nombre unico dentro del pais.';
COMMENT ON COLUMN departamento.id_pais IS 'FK al pais.';

COMMENT ON TABLE municipio IS 'Localidad. Ubicacion de tiendas y residencia de personas.';
COMMENT ON COLUMN municipio.id_municipio IS 'Codigo de municipio (Excel ID_MUN).';
COMMENT ON COLUMN municipio.nombre_municipio IS 'Nombre unico dentro del departamento.';
COMMENT ON COLUMN municipio.id_departamento IS 'FK al departamento.';

COMMENT ON TABLE tipo_tienda IS 'Catalogo de tipos de tienda.';
COMMENT ON TABLE tipo_identificacion IS 'Catalogo de tipos de documento de identidad.';
COMMENT ON TABLE cargo IS 'Catalogo de cargos de empleado.';
COMMENT ON TABLE categoria IS 'Catalogo de categorias de producto.';
COMMENT ON TABLE marca IS 'Catalogo de marcas de producto.';
COMMENT ON TABLE estado_venta IS 'Catalogo de estados: REGISTRADA, PAGADA, ANULADA.';
COMMENT ON TABLE metodo_pago IS 'Catalogo de metodos de pago.';

COMMENT ON TABLE persona IS 'Generalizacion de persona natural (empleado y/o cliente). No es entidad del PDF; se introduce por el dataset.';
COMMENT ON COLUMN persona.correo IS 'Opcional. UNIQUE; Oracle permite varios NULL.';
COMMENT ON COLUMN persona.id_municipio IS 'Municipio de residencia.';

COMMENT ON TABLE tienda IS 'Sucursal de la red.';
COMMENT ON TABLE empleado IS 'Rol laboral de una persona en una tienda y un cargo.';
COMMENT ON COLUMN empleado.id_persona IS 'FK unica: una persona a lo sumo un empleado.';
COMMENT ON TABLE cliente IS 'Rol de cliente de una persona.';
COMMENT ON COLUMN cliente.numero_identificacion IS 'Identificador en texto, no cantidad.';
COMMENT ON COLUMN cliente.id_persona IS 'FK unica: una persona a lo sumo un cliente.';

COMMENT ON TABLE producto IS 'Producto de catalogo general. Precio y existencia NO viven aqui.';
COMMENT ON TABLE catalogo_producto IS 'Oferta por sucursal: precio vigente y existencia de (tienda, producto).';
COMMENT ON COLUMN catalogo_producto.precio_vigente IS 'Precio actual en esa tienda. CHECK > 0.';
COMMENT ON COLUMN catalogo_producto.existencia_actual IS 'Stock actual. CHECK >= 0.';

COMMENT ON TABLE venta IS 'Cabecera de venta. El total NO se almacena; se calcula con SUM(detalle.subtotal).';
COMMENT ON TABLE detalle_venta IS 'Linea de venta. Precio historico del momento. PK (id_venta, id_producto).';
COMMENT ON COLUMN detalle_venta.subtotal IS 'cantidad * precio_unitario. CHECK de igualdad.';
COMMENT ON TABLE pago IS 'Abono a una venta. Una venta puede tener 0..N pagos.';

PROMPT === Tablas creadas ===
SELECT table_name FROM user_tables ORDER BY table_name;

PROMPT === 03_creacion_DB.sql finalizado ===
