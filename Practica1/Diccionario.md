# Diccionario de Datos
## Sistema de Gestión de Prácticas Profesionales Supervisadas (EPS)
### Práctica 1 — Bases de Datos 1

| Dato | Valor |
|---|---|
| **Estudiante** | Josue Daniel Herrera Cottom |
| **Carné** | 202300689 |
| **Curso** | Bases de Datos 1 |
| **Entrega** | `[BD1]_Practica1_202300689.zip` |

---
### EMPRESA

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| EMPRESA | id_empresa | NUMBER | PK | NOT NULL | Identificador t�cnico de la empresa (SUPUESTO de implementaci�n). |
| EMPRESA | nombre | VARCHAR2(150) | Ninguna | NOT NULL | Nombre de la empresa afiliada. |
| EMPRESA | direccion | VARCHAR2(250) | Ninguna | NOT NULL | Direcci�n de la empresa. |
| EMPRESA | sector_economico | VARCHAR2(20) | Ninguna | CHECK: Industria, Servicios, Comercio, Tecnolog�a | Sector econ�mico de la empresa. |

---

### CONTACTO_EMPRESARIAL

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| CONTACTO_EMPRESARIAL | id_contacto | NUMBER | PK | NOT NULL | Identificador t�cnico del contacto (SUPUESTO). |
| CONTACTO_EMPRESARIAL | id_empresa | NUMBER | FK ? EMPRESA | NOT NULL | Empresa a la que pertenece el contacto. |
| CONTACTO_EMPRESARIAL | nombre | VARCHAR2(150) | Ninguna | NOT NULL | Nombre del contacto empresarial. |
| CONTACTO_EMPRESARIAL | telefono | VARCHAR2(20) | Ninguna | NOT NULL | Tel�fono del contacto. |
| CONTACTO_EMPRESARIAL | correo | VARCHAR2(120) | Ninguna | NOT NULL | Correo electr�nico del contacto. |

---

### PLAZA_PRACTICA

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| PLAZA_PRACTICA | id_plaza | NUMBER | PK | NOT NULL | Identificador t�cnico de la plaza (SUPUESTO). |
| PLAZA_PRACTICA | id_empresa | NUMBER | FK ? EMPRESA | NOT NULL | Empresa due�a de la plaza. |
| PLAZA_PRACTICA | id_contacto | NUMBER | FK ? CONTACTO_EMPRESARIAL | NOT NULL | Contacto empresarial responsable de la plaza. |
| PLAZA_PRACTICA | especialidad_tecnica | VARCHAR2(100) | Ninguna | NOT NULL | Especialidad t�cnica asociada a la plaza. |

---

### INSTITUTO_TECNICO

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| INSTITUTO_TECNICO | id_instituto | NUMBER | PK | NOT NULL | Identificador t�cnico del instituto (SUPUESTO). |
| INSTITUTO_TECNICO | nombre | VARCHAR2(150) | Ninguna | NOT NULL | Nombre del instituto t�cnico. |
| INSTITUTO_TECNICO | direccion | VARCHAR2(250) | Ninguna | NOT NULL | Direcci�n del instituto. |
| INSTITUTO_TECNICO | codigo_autorizacion | VARCHAR2(50) | Ninguna | NOT NULL, UNIQUE | C�digo de autorizaci�n del Ministerio de Educaci�n. |

---

### CATEDRATICO_SUPERVISOR

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| CATEDRATICO_SUPERVISOR | id_catedratico | NUMBER | PK | NOT NULL | Identificador t�cnico del catedr�tico (SUPUESTO). |
| CATEDRATICO_SUPERVISOR | id_instituto | NUMBER | FK ? INSTITUTO_TECNICO | NOT NULL | Instituto que asigna al catedr�tico. |
| CATEDRATICO_SUPERVISOR | nombre | VARCHAR2(150) | Ninguna | NOT NULL | Nombre del catedr�tico supervisor. |
| CATEDRATICO_SUPERVISOR | identificacion | VARCHAR2(30) | Ninguna | NOT NULL, UNIQUE | Identificaci�n del catedr�tico. |
| CATEDRATICO_SUPERVISOR | telefono | VARCHAR2(20) | Ninguna | NOT NULL | Tel�fono del catedr�tico. |
| CATEDRATICO_SUPERVISOR | especialidad_que_supervisa | VARCHAR2(100) | Ninguna | NOT NULL | Especialidad que supervisa. |

---

### ESTUDIANTE

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| ESTUDIANTE | carne | VARCHAR2(20) | PK | NOT NULL | Carn� del estudiante (clave natural del enunciado). |
| ESTUDIANTE | nombre_completo | VARCHAR2(150) | Ninguna | NOT NULL | Nombre completo del estudiante. |
| ESTUDIANTE | carrera_tecnica | VARCHAR2(100) | Ninguna | NOT NULL | Carrera t�cnica del estudiante. |
| ESTUDIANTE | direccion | VARCHAR2(250) | Ninguna | NOT NULL | Direcci�n del estudiante. |
| ESTUDIANTE | telefono | VARCHAR2(20) | Ninguna | NOT NULL | Tel�fono del estudiante. |
| ESTUDIANTE | fecha_nacimiento | DATE | Ninguna | NOT NULL | Fecha de nacimiento. |
| ESTUDIANTE | genero | VARCHAR2(20) | Ninguna | NOT NULL | G�nero del estudiante. |
| ESTUDIANTE | departamento | VARCHAR2(80) | Ninguna | NOT NULL | Departamento de residencia (opci�n B: atributo directo). |
| ESTUDIANTE | municipio_residencia | VARCHAR2(80) | Ninguna | NOT NULL | Municipio de residencia (opci�n B: atributo directo). |
| ESTUDIANTE | primera_practica_repitencia | VARCHAR2(20) | Ninguna | NOT NULL | Indica si es primera pr�ctica o repitencia. |

---

### COLOCACION

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| COLOCACION | id_colocacion | NUMBER | PK | NOT NULL | Identificador t�cnico de la colocaci�n (SUPUESTO). |
| COLOCACION | carne | VARCHAR2(20) | FK ? ESTUDIANTE | NOT NULL | Estudiante colocado. |
| COLOCACION | id_plaza | NUMBER | FK ? PLAZA_PRACTICA | NOT NULL | Plaza asignada. |
| COLOCACION | id_catedratico | NUMBER | FK ? CATEDRATICO_SUPERVISOR | NOT NULL | Catedr�tico supervisor asignado. |
| COLOCACION | fecha_inicio | DATE | Ninguna | NOT NULL | Fecha de inicio de la colocaci�n. |
| COLOCACION | fecha_finalizacion | DATE | Ninguna | NULL permitido | Fecha de finalizaci�n de la colocaci�n. |
| COLOCACION | estado | VARCHAR2(15) | Ninguna | CHECK: Activa, Finalizada, Cancelada | Estado de la colocaci�n. Regla: m�x. 1 Activa por estudiante. |

---

### BITACORA

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| BITACORA | id_bitacora | NUMBER | PK | NOT NULL | Identificador t�cnico de la entrada (SUPUESTO). |
| BITACORA | id_colocacion | NUMBER | FK ? COLOCACION | NOT NULL | Colocaci�n a la que pertenece la entrada. |
| BITACORA | id_contacto | NUMBER | FK ? CONTACTO_EMPRESARIAL | NOT NULL | Contacto empresarial que valida la entrada. |
| BITACORA | correlativo | NUMBER | Ninguna | NOT NULL, >= 1 | Correlativo mensual; reinicia en 1 cada mes. Unicidad l�gica con (colocaci�n, a�o-mes(fecha), correlativo). |
| BITACORA | fecha | DATE | Ninguna | NOT NULL | Fecha de la entrada; de ella se deriva el mes. |
| BITACORA | horas_trabajadas | NUMBER(5,2) | Ninguna | NOT NULL, > 0 | Horas trabajadas en el d�a. |
| BITACORA | actividades_realizadas | VARCHAR2(1000) | Ninguna | NOT NULL | Actividades realizadas. |
| BITACORA | observaciones | VARCHAR2(1000) | Ninguna | NULL permitido | Observaciones de la entrada. |

---

### EVALUACION

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| EVALUACION | id_evaluacion | NUMBER | PK | NOT NULL | Identificador t�cnico de la evaluaci�n (SUPUESTO). Los atributos dependen de esta PK. |
| EVALUACION | id_colocacion | NUMBER | FK ? COLOCACION | NOT NULL | Colocaci�n evaluada. |
| EVALUACION | id_catedratico | NUMBER | FK ? CATEDRATICO_SUPERVISOR | NOT NULL | Catedr�tico que realiza la evaluaci�n. |
| EVALUACION | tipo | VARCHAR2(10) | Ninguna | CHECK: Parcial, Final; UNIQUE(id_colocacion, tipo) SUPUESTO | Momento de evaluaci�n (100 h / 200 h). |

---

### CRITERIO_EVALUACION

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| CRITERIO_EVALUACION | id_criterio | NUMBER | PK | NOT NULL | Identificador t�cnico del criterio (SUPUESTO). |
| CRITERIO_EVALUACION | nombre_criterio | VARCHAR2(100) | Ninguna | NOT NULL, UNIQUE | Nombre del criterio (ej.: puntualidad, actitud). Cat�logo abierto. |

---

### DETALLE_EVALUACION

| Entidad | Atributo | Tipo de dato Oracle | Clave | Dominio / Restricci�n | Descripci�n de negocio |
|---|---|---|---|---|---|
| DETALLE_EVALUACION | id_evaluacion | NUMBER | PK / FK ? EVALUACION | NOT NULL | Parte de la PK compuesta; evaluaci�n calificada. |
| DETALLE_EVALUACION | id_criterio | NUMBER | PK / FK ? CRITERIO_EVALUACION | NOT NULL | Parte de la PK compuesta; criterio utilizado. |
| DETALLE_EVALUACION | puntuacion | NUMBER(1) | Ninguna | CHECK: 1, 2, 3, 4, 5 | Puntaje del criterio en esa evaluaci�n. DF: (id_evaluacion, id_criterio) ? puntuacion. |

---

### Notas de supuestos documentados

1. Los `id_*` son identificadores t�cnicos de implementaci�n.
2. `UNIQUE(id_colocacion, tipo)` en EVALUACION es supuesto de negocio.
3. No existen columnas `mes`/`anio` en BITACORA; el mes se deriva de `fecha`.
4. Opci�n B: departamento y municipio permanecen en ESTUDIANTE; no hay entidad MUNICIPIO.
5. La FK `id_contacto` en BITACORA representa la validaci�n exigida por el enunciado.
