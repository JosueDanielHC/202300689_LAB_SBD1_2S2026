# Guía de estudio y defensa — Práctica 1 (BD1)

**Estudiante:** Josue Daniel Herrera Cottom  
**Carné:** 202300689  
**Curso:** Bases de Datos 1 — Segundo Semestre 2026  
**Entrega:** `[BD1]_Practica1_202300689.zip`

Esta guía resume **cómo se construyó el proyecto**, **para qué sirve cada archivo** y **qué debes saber defender** en la calificación.

---

## 1. ¿Qué problema resuelve este proyecto?

La Dirección Académica necesita una base de datos para controlar el programa de **EPS (Prácticas Profesionales Supervisadas)** de estudiantes de institutos técnicos en empresas afiliadas.

Hoy lo llevan en Excel y bitácoras físicas. El sistema debe permitir:

1. Registrar empresas, contactos, plazas, institutos, catedráticos y estudiantes.
2. Asignar **colocaciones** (estudiante ↔ plaza).
3. Registrar **bitácoras** diarias validadas por el contacto empresarial.
4. Registrar **evaluaciones** parcial (100 h) y final (200 h) con criterios puntuados 1–5.

**Alcance (del enunciado):** colocación, bitácora y evaluación.  
**NO incluye:** nómina, pagos ni convenios legales.

---

## 2. Organización de carpetas y archivos

```
Bases1/
└── labbases1/
    ├── Practica1.pdf              ← Enunciado oficial
    └── Practica1/                 ← Carpeta de trabajo / entregables
        ├── [BD1]_Practica1_202300689.zip   ← PAQUETE DE ENTREGA
        ├── Diccionario.pdf
        ├── Diccionario.md                 ← Borrador editable del diccionario
        ├── ModeloConceptual.png           ← Diagrama conceptual (draw.io)
        ├── ModeloLogico.png
        ├── ModeloRelacional.png
        ├── DDL.sql                        ← Creación de tablas Oracle
        ├── DatosPrueba.sql                ← INSERT de prueba (NO es entregable)
        └── generar_entregables.py         ← Script auxiliar (NO es entregable)
```

### ¿Qué va DENTRO del ZIP de entrega?

Solo estos **5 archivos** (nombres exactos, sin espacios):

| Archivo | Qué demuestra |
|---|---|
| `Diccionario.pdf` | Todas las entidades/atributos con tipo, clave, dominio y descripción |
| `ModeloConceptual.png` | Visión de negocio: entidades, relaciones, cardinalidades (sin tipos Oracle) |
| `ModeloLogico.png` | Tablas, PK, FK, resolución N:M |
| `ModeloRelacional.png` | Mismo modelo con tipos de dato Oracle |
| `DDL.sql` | Script que crea tablas, PK, FK y CHECK/UNIQUE en Oracle |

### ¿Qué NO va en el ZIP (pero sí te sirve para estudiar/probar)?

| Archivo | Propósito |
|---|---|
| `Diccionario.md` | Fuente editable del diccionario (se exportó/generó el PDF desde aquí) |
| `DatosPrueba.sql` | 2–3 filas por tabla para probar que el DDL funciona |
| `generar_entregables.py` | Automatizó PDF/PNG/ZIP; **no** sustituye Oracle SQL Data Modeler ante el auxiliar |
| Esta guía | Material de estudio / defensa |

---

## 3. Flujo de construcción (cómo se hizo el proyecto)

Trabajamos por **fases**, sin saltar al DDL primero (el enunciado **prohíbe** crear DDL y luego hacer ingeniería inversa).

```
FASE 0  Comprensión del problema
   ↓
FASE 1  Análisis sistemático (entidades, atributos, relaciones, reglas)
   ↓
FASE 2  Modelo conceptual (draw.io)  →  ModeloConceptual.png
   ↓
FASE 3  Normalización 1FN → 2FN → 3FN
   ↓
FASE 4  Modelo lógico (PK, FK, DETALLE_EVALUACION)
   ↓
FASE 5  DDL Oracle + diccionario + empaquetado
   ↓
(Manual recomendado) Oracle SQL Data Modeler → ModeloLogico / ModeloRelacional
```

### Resumen de cada fase

| Fase | Qué se hizo | Resultado |
|---|---|---|
| **0** | Entender actores y proceso EPS | Listas iniciales |
| **1** | Extraer del PDF: entidades, atributos, relaciones, cardinalidades | Análisis validado contra el enunciado |
| **2** | Dibujar ER conceptual; corregir omisiones (Contacto–Plaza, Catedrático–Evaluación) | `ModeloConceptual.png` |
| **3** | Revisar 1FN/2FN/3FN; decisión **B** (depto/municipio en Estudiante) | Justificación de normalización |
| **4** | Definir 11 tablas, PK/FK, supuestos | Modelo lógico aprobado |
| **5** | Escribir `DDL.sql`, diccionario, datos de prueba, ZIP | Entregables |

---

## 4. Lógica del modelo de datos (el “corazón” del proyecto)

### 4.1 Las 11 tablas

| # | Tabla | Rol en el negocio |
|---|---|---|
| 1 | `EMPRESA` | Empresa afiliada al programa |
| 2 | `CONTACTO_EMPRESARIAL` | Supervisor externo de la empresa |
| 3 | `PLAZA_PRACTICA` | Cupo/oferta de práctica en una empresa |
| 4 | `INSTITUTO_TECNICO` | Instituto que envía estudiantes |
| 5 | `CATEDRATICO_SUPERVISOR` | Supervisor académico del instituto |
| 6 | `ESTUDIANTE` | Estudiante del programa |
| 7 | `COLOCACION` | Asignación estudiante–plaza (núcleo del proceso) |
| 8 | `BITACORA` | Entrada diaria de asistencia/actividades |
| 9 | `EVALUACION` | Evaluación Parcial o Final |
| 10 | `CRITERIO_EVALUACION` | Catálogo de criterios (puntualidad, etc.) |
| 11 | `DETALLE_EVALUACION` | Puntaje 1–5 de un criterio **en** una evaluación |

### 4.2 Por qué `COLOCACION` es el centro

Casi todo gira alrededor de la colocación:

```
ESTUDIANTE ──┐
PLAZA ───────┼──► COLOCACION ──► BITACORA
CATEDRATICO ─┘         │
                       └──► EVALUACION ──► DETALLE_EVALUACION ──► CRITERIO
```

- Un estudiante pide una **plaza** → nace una **colocación**.
- Cada día registra **bitácora** de esa colocación.
- Al llegar a 100/200 horas se hacen **evaluaciones** de esa colocación.

### 4.3 Mapa de relaciones (cardinalidades)

```
EMPRESA 1 ──< N CONTACTO
EMPRESA 1 ──< N PLAZA
CONTACTO 1 ──< N PLAZA          (responsable)
INSTITUTO 1 ──< N CATEDRATICO
ESTUDIANTE 1 ──< N COLOCACION   (+ máx. 1 Activa)
PLAZA 1 ──< N COLOCACION
CATEDRATICO 1 ──< N COLOCACION
COLOCACION 1 ──< N BITACORA
CONTACTO 1 ──< N BITACORA       (valida)
COLOCACION 1 ──< N EVALUACION
CATEDRATICO 1 ──< N EVALUACION  (realiza)
EVALUACION 1 ──< N DETALLE
CRITERIO 1 ──< N DETALLE
```

### 4.4 Decisión importante: NO hay relación directa Instituto–Estudiante

El enunciado dice que los institutos “envían estudiantes”, pero **no** pone el instituto entre los datos del estudiante.

**Decisión B:** el instituto se conoce vía:

`COLOCACION → CATEDRATICO → INSTITUTO`

Así no inventamos una FK que el enunciado no pide explícitamente.

---

## 5. Decisiones de diseño que DEBES saber defender

### A) IDs técnicos (`id_empresa`, `id_plaza`, …)

- **No** vienen del enunciado.
- Son **SUPUESTO de implementación** para tener PK clara donde no hay clave natural.
- Excepción: `ESTUDIANTE.carne` **sí** es clave natural del enunciado.

### B) Departamento y municipio en `ESTUDIANTE` (opción B)

- El enunciado los lista como datos del estudiante.
- **No** se creó tabla `MUNICIPIO`.
- **Supuesto:** no se asume la DF municipio→departamento porque el enunciado no la establece ni pide catálogo geográfico.

### C) `DETALLE_EVALUACION` (clave compuesta)

- El enunciado: cada criterio se puntúa **dentro de esa evaluación**.
- Relación N:M entre `EVALUACION` y `CRITERIO`.
- Tabla asociativa con PK `(id_evaluacion, id_criterio)`.
- Dependencia funcional correcta:

  `(id_evaluacion, id_criterio) → puntuacion`

  (**No** al revés: la puntuación no identifica la fila.)

### D) Bitácora sin columnas `mes` / `anio`

- El correlativo reinicia cada mes.
- Ya existe el atributo `fecha`.
- El mes se **deriva** de `fecha`.
- Unicidad lógica: `(id_colocacion, año-mes(fecha), correlativo)`.
- Agregar `mes`/`anio` sería redundante (peor para 3FN).

### E) `id_catedratico` en COLOCACIÓN **y** en EVALUACIÓN

- El enunciado menciona ambas cosas por separado.
- Puede haber redundancia (suele ser el mismo catedrático).
- Se mantienen ambas FK por **fidelidad al enunciado**.

### F) `id_contacto` en PLAZA **y** en BITÁCORA

- Plaza: contacto **responsable**.
- Bitácora: contacto que **valida** la entrada.
- La forma exacta de “guardar validación” (solo FK vs flag extra) es supuesto; la relación sí es obligatoria.

### G) `UNIQUE (id_colocacion, tipo)` en EVALUACIÓN

- **SUPUESTO** de negocio: como máximo una Parcial y una Final por colocación.
- Alineado a “2 momentos” (100 h / 200 h), aunque el enunciado no diga “UNIQUE” literalmente.

### H) Justificación 3FN (respuesta corta para oral)

1. **1FN:** atributos atómicos; sin listas dentro de un campo.  
2. **2FN:** en `DETALLE_EVALUACION`, `puntuacion` depende de **toda** la PK compuesta.  
3. **3FN:** no se repiten datos de otras entidades; se usan FK. Con opción B no inventamos catálogo geográfico.

---

## 6. Qué hace el `DDL.sql` (lógica del script)

Orden del script:

1. **`DROP TABLE ... CASCADE CONSTRAINTS`** (hijos primero) → permite reejecutar limpio.
2. **`CREATE TABLE`** (padres primero) → respeta FKs.
3. Restricciones:
   - `PRIMARY KEY`
   - `FOREIGN KEY`
   - `CHECK` (sector, estado, tipo, puntuación)
   - `UNIQUE` (código instituto, identificación catedrático, colocación+tipo)

Orden de creación:

```
EMPRESA, INSTITUTO, ESTUDIANTE, CRITERIO
→ CONTACTO, CATEDRATICO
→ PLAZA
→ COLOCACION
→ BITACORA, EVALUACION
→ DETALLE_EVALUACION
```

### Cómo probarlo en Oracle

```text
1) Ejecutar DDL.sql
2) Ejecutar DatosPrueba.sql
3) SELECT * FROM EMPRESA;
   SELECT * FROM COLOCACION;
   SELECT * FROM DETALLE_EVALUACION;
```

Si falla un INSERT, casi siempre es: orden FK incorrecto, valor fuera de CHECK, o UNIQUE violado.

---

## 7. Rúbrica: dónde está cada puntaje

| Criterio | Pts | Cómo lo cubrimos |
|---|---|---|
| Diccionario | 10 | `Diccionario.pdf` completo |
| Modelo conceptual | 15 | `ModeloConceptual.png` (10 entidades + 12 relaciones) |
| Presentación / nombres | 5 | Nombres exactos + ZIP correcto |
| Preguntas teóricas | 10 | Ver sección 8 |
| Modelo lógico | 20 | PK/FK/3FN + `DETALLE_EVALUACION` |
| Modelo relacional | 15 | Tipos Oracle + integridad referencial |
| Script DDL | 25 | Ejecutable en Oracle con restricciones |

**Requisito crítico §8.1:** el lógico/relacional deben elaborarse en **Oracle SQL Data Modeler**.  
Si tus PNG se generaron por script, en una exposición conviene decir:

> “El modelo lógico aprobado se implementó en DDL y se documentó en diagramas; para cumplir la herramienta obligatoria, el diagrama oficial de calificación es el exportado desde Oracle SQL Data Modeler.”

Si aún no los sacaste de Data Modeler, **hazlo** y reemplaza los PNG del ZIP.

---

## 8. Banco rápido de defensa oral

### P1. ¿Cuáles son las entidades principales?
Empresa, Contacto, Plaza, Instituto, Catedrático, Estudiante, Colocación, Bitácora, Evaluación, Criterio (+ Detalle_Evaluación en el lógico).

### P2. ¿Qué es una colocación?
La asignación de un estudiante a una plaza, con fechas, catedrático y estado (Activa/Finalizada/Cancelada). Un estudiante solo puede tener **una Activa** a la vez.

### P3. ¿Por qué existe `DETALLE_EVALUACION`?
Porque la puntuación pertenece al vínculo Evaluación–Criterio (N:M), no al criterio solo.

### P4. ¿Por qué no hay tabla Municipio?
Opción B: el enunciado los define como atributos del estudiante y no exige catálogo.

### P5. ¿Cómo reinicia el correlativo de bitácora?
Por mes, derivado de `fecha`; no se guardan columnas mes/año.

### P6. ¿El DDL se hizo primero?
No. Primero conceptual → normalización → lógico → luego DDL. El enunciado prohíbe ingeniería inversa.

### P7. ¿Qué CHECK importantes hay?
- Sector: Industria, Servicios, Comercio, Tecnología  
- Estado: Activa, Finalizada, Cancelada  
- Tipo: Parcial, Final  
- Puntuación: 1 a 5  

---

## 9. Si te piden una modificación en la evaluación

| Pedido típico | Qué harías |
|---|---|
| Agregar Instituto–Estudiante | Agregar FK `id_instituto` en `ESTUDIANTE` y documentar el supuesto |
| Quitar catedrático de Evaluación | Dejarlo solo en Colocación y validar por consulta/trigger |
| Forzar 3FN geográfica | Crear `MUNICIPIO` / `DEPARTAMENTO` y referenciar desde Estudiante |
| Una bitácora por día | UNIQUE `(id_colocacion, fecha)` (supuesto adicional) |
| Cambiar PK de estudiante | Pasar a `id_estudiante` y dejar `carne` UNIQUE |

Siempre: **cambiar conceptual/lógico → luego DDL → regenerar diccionario**.

---

## 10. Checklist mental antes de exponer

- [ ] Sé explicar el proceso: Empresa/Plaza → Colocación → Bitácora/Evaluación  
- [ ] Sé nombrar las 11 tablas y para qué sirve cada una  
- [ ] Sé justificar `DETALLE_EVALUACION` y la DF de `puntuacion`  
- [ ] Sé explicar opción B (municipio/departamento)  
- [ ] Sé explicar bitácora sin mes/año  
- [ ] Sé decir qué es supuesto y qué viene del enunciado  
- [ ] Sé el nombre exacto del ZIP y de los 5 archivos  
- [ ] Puedo ejecutar mentalmente el orden de CREATE/INSERT  

---

## 11. Mensaje final para tu defensa

> Diseñé el modelo partiendo del enunciado oficial: primero identifiqué entidades y reglas, luego el modelo conceptual, después normalicé hasta 3FN (con supuestos documentados), transformé a modelo lógico con PK/FK y resolví el N:M Evaluación–Criterio en `DETALLE_EVALUACION`, y finalmente generé el DDL compatible con Oracle. El núcleo del negocio es la **Colocación**, porque conecta estudiante, plaza, supervisión académica, bitácora y evaluación.

Con esto puedes estudiar, explicar y modificar el proyecto con criterio.
