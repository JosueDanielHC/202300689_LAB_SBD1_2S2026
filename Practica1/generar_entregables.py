# -*- coding: utf-8 -*-
"""Genera Diccionario.pdf, ModeloLogico.png, ModeloRelacional.png y el ZIP final."""
from __future__ import annotations

import zipfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
    PageBreak,
)

ROOT = Path(r"C:\Users\CompuFire\Documents\SegundoSemestre2026\Bases1\labbases1\Practica1")
STUDENT = "Josue Daniel Herrera Cottom"
CARNET = "202300689"
ZIP_NAME = f"[BD1]_Practica1_{CARNET}.zip"

# ---------------------------------------------------------------------------
# Diccionario (datos aprobados)
# ---------------------------------------------------------------------------
DICCIONARIO = {
    "EMPRESA": [
        ["id_empresa", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        ["nombre", "VARCHAR2(150)", "—", "NOT NULL", "Nombre de la empresa afiliada."],
        ["direccion", "VARCHAR2(250)", "—", "NOT NULL", "Dirección de la empresa."],
        [
            "sector_economico",
            "VARCHAR2(20)",
            "—",
            "Industria/Servicios/Comercio/Tecnología",
            "Sector económico de la empresa.",
        ],
    ],
    "CONTACTO_EMPRESARIAL": [
        ["id_contacto", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        ["id_empresa", "NUMBER", "FK→EMPRESA", "NOT NULL", "Empresa del contacto."],
        ["nombre", "VARCHAR2(150)", "—", "NOT NULL", "Nombre del contacto."],
        ["telefono", "VARCHAR2(20)", "—", "NOT NULL", "Teléfono."],
        ["correo", "VARCHAR2(120)", "—", "NOT NULL", "Correo electrónico."],
    ],
    "PLAZA_PRACTICA": [
        ["id_plaza", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        ["id_empresa", "NUMBER", "FK→EMPRESA", "NOT NULL", "Empresa dueña de la plaza."],
        [
            "id_contacto",
            "NUMBER",
            "FK→CONTACTO",
            "NOT NULL",
            "Contacto responsable de la plaza.",
        ],
        [
            "especialidad_tecnica",
            "VARCHAR2(100)",
            "—",
            "NOT NULL",
            "Especialidad técnica de la plaza.",
        ],
    ],
    "INSTITUTO_TECNICO": [
        ["id_instituto", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        ["nombre", "VARCHAR2(150)", "—", "NOT NULL", "Nombre del instituto."],
        ["direccion", "VARCHAR2(250)", "—", "NOT NULL", "Dirección."],
        [
            "codigo_autorizacion",
            "VARCHAR2(50)",
            "—",
            "NOT NULL, UNIQUE",
            "Código de autorización MINEDUC.",
        ],
    ],
    "CATEDRATICO_SUPERVISOR": [
        ["id_catedratico", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        ["id_instituto", "NUMBER", "FK→INSTITUTO", "NOT NULL", "Instituto que lo asigna."],
        ["nombre", "VARCHAR2(150)", "—", "NOT NULL", "Nombre del catedrático."],
        [
            "identificacion",
            "VARCHAR2(30)",
            "—",
            "NOT NULL, UNIQUE",
            "Identificación del catedrático.",
        ],
        ["telefono", "VARCHAR2(20)", "—", "NOT NULL", "Teléfono."],
        [
            "especialidad_que_supervisa",
            "VARCHAR2(100)",
            "—",
            "NOT NULL",
            "Especialidad que supervisa.",
        ],
    ],
    "ESTUDIANTE": [
        ["carne", "VARCHAR2(20)", "PK", "NOT NULL", "Carné (clave natural del enunciado)."],
        ["nombre_completo", "VARCHAR2(150)", "—", "NOT NULL", "Nombre completo."],
        ["carrera_tecnica", "VARCHAR2(100)", "—", "NOT NULL", "Carrera técnica."],
        ["direccion", "VARCHAR2(250)", "—", "NOT NULL", "Dirección."],
        ["telefono", "VARCHAR2(20)", "—", "NOT NULL", "Teléfono."],
        ["fecha_nacimiento", "DATE", "—", "NOT NULL", "Fecha de nacimiento."],
        ["genero", "VARCHAR2(20)", "—", "NOT NULL", "Género."],
        [
            "departamento",
            "VARCHAR2(80)",
            "—",
            "NOT NULL",
            "Departamento (opción B: atributo directo).",
        ],
        [
            "municipio_residencia",
            "VARCHAR2(80)",
            "—",
            "NOT NULL",
            "Municipio (opción B: atributo directo).",
        ],
        [
            "primera_practica_repitencia",
            "VARCHAR2(20)",
            "—",
            "NOT NULL",
            "Primera práctica o repitencia.",
        ],
    ],
    "COLOCACION": [
        ["id_colocacion", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        ["carne", "VARCHAR2(20)", "FK→ESTUDIANTE", "NOT NULL", "Estudiante colocado."],
        ["id_plaza", "NUMBER", "FK→PLAZA", "NOT NULL", "Plaza asignada."],
        [
            "id_catedratico",
            "NUMBER",
            "FK→CATEDRATICO",
            "NOT NULL",
            "Catedrático supervisor asignado.",
        ],
        ["fecha_inicio", "DATE", "—", "NOT NULL", "Fecha de inicio."],
        ["fecha_finalizacion", "DATE", "—", "NULL permitido", "Fecha de finalización."],
        [
            "estado",
            "VARCHAR2(15)",
            "—",
            "Activa/Finalizada/Cancelada",
            "Estado; máx. 1 Activa por estudiante.",
        ],
    ],
    "BITACORA": [
        ["id_bitacora", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        ["id_colocacion", "NUMBER", "FK→COLOCACION", "NOT NULL", "Colocación asociada."],
        [
            "id_contacto",
            "NUMBER",
            "FK→CONTACTO",
            "NOT NULL",
            "Contacto que valida la entrada.",
        ],
        [
            "correlativo",
            "NUMBER",
            "—",
            ">= 1",
            "Correlativo mensual; reinicia cada mes.",
        ],
        ["fecha", "DATE", "—", "NOT NULL", "Fecha; de ella se deriva el mes."],
        ["horas_trabajadas", "NUMBER(5,2)", "—", "> 0", "Horas trabajadas."],
        [
            "actividades_realizadas",
            "VARCHAR2(1000)",
            "—",
            "NOT NULL",
            "Actividades realizadas.",
        ],
        ["observaciones", "VARCHAR2(1000)", "—", "NULL permitido", "Observaciones."],
    ],
    "EVALUACION": [
        [
            "id_evaluacion",
            "NUMBER",
            "PK",
            "NOT NULL",
            "Identificador técnico; atributos dependen de esta PK.",
        ],
        ["id_colocacion", "NUMBER", "FK→COLOCACION", "NOT NULL", "Colocación evaluada."],
        [
            "id_catedratico",
            "NUMBER",
            "FK→CATEDRATICO",
            "NOT NULL",
            "Catedrático que realiza la evaluación.",
        ],
        [
            "tipo",
            "VARCHAR2(10)",
            "—",
            "Parcial/Final; UNIQUE(id_colocacion,tipo) SUPUESTO",
            "Momento de evaluación (100 h / 200 h).",
        ],
    ],
    "CRITERIO_EVALUACION": [
        ["id_criterio", "NUMBER", "PK", "NOT NULL", "Identificador técnico (SUPUESTO)."],
        [
            "nombre_criterio",
            "VARCHAR2(100)",
            "—",
            "NOT NULL, UNIQUE",
            "Nombre del criterio (catálogo abierto).",
        ],
    ],
    "DETALLE_EVALUACION": [
        [
            "id_evaluacion",
            "NUMBER",
            "PK+FK→EVALUACION",
            "NOT NULL",
            "Parte de la PK compuesta.",
        ],
        [
            "id_criterio",
            "NUMBER",
            "PK+FK→CRITERIO",
            "NOT NULL",
            "Parte de la PK compuesta.",
        ],
        [
            "puntuacion",
            "NUMBER(1)",
            "—",
            "1..5",
            "DF: (id_evaluacion, id_criterio) → puntuacion.",
        ],
    ],
}

# Tablas para diagramas (lógico ≈ relacional con tipos)
LOGICAL_TABLES = {
    "EMPRESA": [
        ("PK", "id_empresa"),
        ("", "nombre"),
        ("", "direccion"),
        ("", "sector_economico"),
    ],
    "CONTACTO_EMPRESARIAL": [
        ("PK", "id_contacto"),
        ("FK", "id_empresa"),
        ("", "nombre"),
        ("", "telefono"),
        ("", "correo"),
    ],
    "PLAZA_PRACTICA": [
        ("PK", "id_plaza"),
        ("FK", "id_empresa"),
        ("FK", "id_contacto"),
        ("", "especialidad_tecnica"),
    ],
    "INSTITUTO_TECNICO": [
        ("PK", "id_instituto"),
        ("", "nombre"),
        ("", "direccion"),
        ("UQ", "codigo_autorizacion"),
    ],
    "CATEDRATICO_SUPERVISOR": [
        ("PK", "id_catedratico"),
        ("FK", "id_instituto"),
        ("", "nombre"),
        ("UQ", "identificacion"),
        ("", "telefono"),
        ("", "especialidad_que_supervisa"),
    ],
    "ESTUDIANTE": [
        ("PK", "carne"),
        ("", "nombre_completo"),
        ("", "carrera_tecnica"),
        ("", "direccion"),
        ("", "telefono"),
        ("", "fecha_nacimiento"),
        ("", "genero"),
        ("", "departamento"),
        ("", "municipio_residencia"),
        ("", "primera_practica_repitencia"),
    ],
    "COLOCACION": [
        ("PK", "id_colocacion"),
        ("FK", "carne"),
        ("FK", "id_plaza"),
        ("FK", "id_catedratico"),
        ("", "fecha_inicio"),
        ("", "fecha_finalizacion"),
        ("", "estado"),
    ],
    "BITACORA": [
        ("PK", "id_bitacora"),
        ("FK", "id_colocacion"),
        ("FK", "id_contacto"),
        ("", "correlativo"),
        ("", "fecha"),
        ("", "horas_trabajadas"),
        ("", "actividades_realizadas"),
        ("", "observaciones"),
    ],
    "EVALUACION": [
        ("PK", "id_evaluacion"),
        ("FK", "id_colocacion"),
        ("FK", "id_catedratico"),
        ("", "tipo"),
    ],
    "CRITERIO_EVALUACION": [
        ("PK", "id_criterio"),
        ("UQ", "nombre_criterio"),
    ],
    "DETALLE_EVALUACION": [
        ("PK/FK", "id_evaluacion"),
        ("PK/FK", "id_criterio"),
        ("", "puntuacion"),
    ],
}

RELATIONAL_TABLES = {
    "EMPRESA": [
        ("PK", "id_empresa NUMBER"),
        ("", "nombre VARCHAR2(150)"),
        ("", "direccion VARCHAR2(250)"),
        ("", "sector_economico VARCHAR2(20)"),
    ],
    "CONTACTO_EMPRESARIAL": [
        ("PK", "id_contacto NUMBER"),
        ("FK", "id_empresa NUMBER"),
        ("", "nombre VARCHAR2(150)"),
        ("", "telefono VARCHAR2(20)"),
        ("", "correo VARCHAR2(120)"),
    ],
    "PLAZA_PRACTICA": [
        ("PK", "id_plaza NUMBER"),
        ("FK", "id_empresa NUMBER"),
        ("FK", "id_contacto NUMBER"),
        ("", "especialidad_tecnica VARCHAR2(100)"),
    ],
    "INSTITUTO_TECNICO": [
        ("PK", "id_instituto NUMBER"),
        ("", "nombre VARCHAR2(150)"),
        ("", "direccion VARCHAR2(250)"),
        ("UQ", "codigo_autorizacion VARCHAR2(50)"),
    ],
    "CATEDRATICO_SUPERVISOR": [
        ("PK", "id_catedratico NUMBER"),
        ("FK", "id_instituto NUMBER"),
        ("", "nombre VARCHAR2(150)"),
        ("UQ", "identificacion VARCHAR2(30)"),
        ("", "telefono VARCHAR2(20)"),
        ("", "especialidad_que_supervisa VARCHAR2(100)"),
    ],
    "ESTUDIANTE": [
        ("PK", "carne VARCHAR2(20)"),
        ("", "nombre_completo VARCHAR2(150)"),
        ("", "carrera_tecnica VARCHAR2(100)"),
        ("", "direccion VARCHAR2(250)"),
        ("", "telefono VARCHAR2(20)"),
        ("", "fecha_nacimiento DATE"),
        ("", "genero VARCHAR2(20)"),
        ("", "departamento VARCHAR2(80)"),
        ("", "municipio_residencia VARCHAR2(80)"),
        ("", "primera_practica_repitencia VARCHAR2(20)"),
    ],
    "COLOCACION": [
        ("PK", "id_colocacion NUMBER"),
        ("FK", "carne VARCHAR2(20)"),
        ("FK", "id_plaza NUMBER"),
        ("FK", "id_catedratico NUMBER"),
        ("", "fecha_inicio DATE"),
        ("", "fecha_finalizacion DATE"),
        ("", "estado VARCHAR2(15)"),
    ],
    "BITACORA": [
        ("PK", "id_bitacora NUMBER"),
        ("FK", "id_colocacion NUMBER"),
        ("FK", "id_contacto NUMBER"),
        ("", "correlativo NUMBER"),
        ("", "fecha DATE"),
        ("", "horas_trabajadas NUMBER(5,2)"),
        ("", "actividades_realizadas VARCHAR2(1000)"),
        ("", "observaciones VARCHAR2(1000)"),
    ],
    "EVALUACION": [
        ("PK", "id_evaluacion NUMBER"),
        ("FK", "id_colocacion NUMBER"),
        ("FK", "id_catedratico NUMBER"),
        ("", "tipo VARCHAR2(10)"),
    ],
    "CRITERIO_EVALUACION": [
        ("PK", "id_criterio NUMBER"),
        ("UQ", "nombre_criterio VARCHAR2(100)"),
    ],
    "DETALLE_EVALUACION": [
        ("PK/FK", "id_evaluacion NUMBER"),
        ("PK/FK", "id_criterio NUMBER"),
        ("", "puntuacion NUMBER(1)"),
    ],
}

# Relaciones: (from, to, label) — flecha FK from child to parent
RELATIONS = [
    ("CONTACTO_EMPRESARIAL", "EMPRESA", "N:1"),
    ("PLAZA_PRACTICA", "EMPRESA", "N:1"),
    ("PLAZA_PRACTICA", "CONTACTO_EMPRESARIAL", "N:1"),
    ("CATEDRATICO_SUPERVISOR", "INSTITUTO_TECNICO", "N:1"),
    ("COLOCACION", "ESTUDIANTE", "N:1"),
    ("COLOCACION", "PLAZA_PRACTICA", "N:1"),
    ("COLOCACION", "CATEDRATICO_SUPERVISOR", "N:1"),
    ("BITACORA", "COLOCACION", "N:1"),
    ("BITACORA", "CONTACTO_EMPRESARIAL", "N:1"),
    ("EVALUACION", "COLOCACION", "N:1"),
    ("EVALUACION", "CATEDRATICO_SUPERVISOR", "N:1"),
    ("DETALLE_EVALUACION", "EVALUACION", "N:1"),
    ("DETALLE_EVALUACION", "CRITERIO_EVALUACION", "N:1"),
]


def make_pdf() -> Path:
    out = ROOT / "Diccionario.pdf"
    doc = SimpleDocTemplate(
        str(out),
        pagesize=letter,
        leftMargin=0.6 * inch,
        rightMargin=0.6 * inch,
        topMargin=0.55 * inch,
        bottomMargin=0.55 * inch,
    )
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "T",
        parent=styles["Heading1"],
        alignment=TA_CENTER,
        fontSize=14,
        spaceAfter=6,
    )
    subtitle = ParagraphStyle(
        "S",
        parent=styles["Normal"],
        alignment=TA_CENTER,
        fontSize=10,
        spaceAfter=4,
    )
    h2 = ParagraphStyle(
        "H2",
        parent=styles["Heading2"],
        fontSize=11,
        spaceBefore=10,
        spaceAfter=6,
        textColor=colors.HexColor("#1a365d"),
    )
    cell = ParagraphStyle("C", parent=styles["Normal"], fontSize=7, leading=9)
    meta = ParagraphStyle("M", parent=styles["Normal"], fontSize=9, alignment=TA_LEFT)

    story = []
    story.append(Paragraph("Diccionario de Datos", title))
    story.append(
        Paragraph(
            "Sistema de Gestión de Prácticas Profesionales Supervisadas (EPS)",
            subtitle,
        )
    )
    story.append(Paragraph("Práctica 1 — Bases de Datos 1", subtitle))
    story.append(Spacer(1, 6))
    story.append(Paragraph(f"<b>Estudiante:</b> {STUDENT}", meta))
    story.append(Paragraph(f"<b>Carné:</b> {CARNET}", meta))
    story.append(Paragraph(f"<b>Entrega:</b> [BD1]_Practica1_{CARNET}.zip", meta))
    story.append(Spacer(1, 8))

    header = [
        Paragraph("<b>Atributo</b>", cell),
        Paragraph("<b>Tipo Oracle</b>", cell),
        Paragraph("<b>Clave</b>", cell),
        Paragraph("<b>Dominio / Restricción</b>", cell),
        Paragraph("<b>Descripción</b>", cell),
    ]

    for entidad, rows in DICCIONARIO.items():
        story.append(Paragraph(entidad, h2))
        data = [header]
        for attr, tipo, clave, dominio, desc in rows:
            data.append(
                [
                    Paragraph(attr, cell),
                    Paragraph(tipo, cell),
                    Paragraph(clave, cell),
                    Paragraph(dominio, cell),
                    Paragraph(desc, cell),
                ]
            )
        t = Table(data, colWidths=[1.15 * inch, 1.15 * inch, 1.0 * inch, 1.45 * inch, 2.3 * inch])
        t.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#2c5282")),
                    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                    ("GRID", (0, 0), (-1, -1), 0.6, colors.HexColor("#2d3748")),
                    ("BOX", (0, 0), (-1, -1), 1.2, colors.HexColor("#1a202c")),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 3),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 3),
                    ("TOPPADDING", (0, 0), (-1, -1), 3),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
                    (
                        "ROWBACKGROUNDS",
                        (0, 1),
                        (-1, -1),
                        [colors.white, colors.HexColor("#edf2f7")],
                    ),
                ]
            )
        )
        story.append(t)

    story.append(PageBreak())
    story.append(Paragraph("Supuestos documentados", h2))
    supuestos = [
        "1. Los id_* son identificadores técnicos de implementación (no datos del enunciado).",
        "2. UNIQUE(id_colocacion, tipo) en EVALUACION es supuesto de negocio.",
        "3. No hay columnas mes/anio en BITACORA; el mes se deriva de fecha.",
        "4. Opción B: departamento y municipio permanecen en ESTUDIANTE.",
        "5. FK id_contacto en BITACORA representa la validación del enunciado.",
        "6. DETALLE_EVALUACION resuelve N:M; DF: (id_evaluacion, id_criterio) → puntuacion.",
    ]
    for s in supuestos:
        story.append(Paragraph(s, meta))
        story.append(Spacer(1, 3))

    doc.build(story)
    return out


def _font(size: int, bold: bool = False):
    candidates = []
    if bold:
        candidates += [
            r"C:\Windows\Fonts\arialbd.ttf",
            r"C:\Windows\Fonts\segoeuib.ttf",
        ]
    candidates += [
        r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\segoeui.ttf",
        r"C:\Windows\Fonts\calibri.ttf",
    ]
    for p in candidates:
        if Path(p).exists():
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def _measure(draw: ImageDraw.ImageDraw, text: str, font) -> tuple[int, int]:
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


def draw_er_diagram(
    tables: dict[str, list[tuple[str, str]]],
    title: str,
    outfile: Path,
    subtitle: str,
) -> Path:
    # Layout positions (approximate grid)
    positions = {
        "EMPRESA": (40, 40),
        "CONTACTO_EMPRESARIAL": (320, 40),
        "PLAZA_PRACTICA": (640, 40),
        "INSTITUTO_TECNICO": (960, 40),
        "CATEDRATICO_SUPERVISOR": (960, 320),
        "ESTUDIANTE": (40, 360),
        "COLOCACION": (360, 360),
        "BITACORA": (40, 720),
        "EVALUACION": (640, 360),
        "CRITERIO_EVALUACION": (1000, 700),
        "DETALLE_EVALUACION": (640, 700),
    }

    font_title = _font(22, True)
    font_sub = _font(12, False)
    font_hdr = _font(12, True)
    font_row = _font(11, False)
    font_badge = _font(9, True)

    # First pass: compute box sizes
    dummy = Image.new("RGB", (10, 10), "white")
    d0 = ImageDraw.Draw(dummy)
    boxes: dict[str, tuple[int, int, int, int]] = {}
    pad_x, row_h, hdr_h = 10, 18, 28

    for name, cols in tables.items():
        tw, _ = _measure(d0, name, font_hdr)
        max_w = tw
        for badge, col in cols:
            label = f"{badge + ' ' if badge else ''}{col}"
            w, _ = _measure(d0, label, font_row)
            max_w = max(max_w, w)
        width = max(180, max_w + 2 * pad_x + 8)
        height = hdr_h + len(cols) * row_h + 8
        x, y = positions[name]
        boxes[name] = (x, y, width, height)

    # Canvas size
    max_r = max(x + w for x, y, w, h in boxes.values()) + 40
    max_b = max(y + h for x, y, w, h in boxes.values()) + 80
    img = Image.new("RGB", (max_r, max_b), "#f7fafc")
    draw = ImageDraw.Draw(img)

    draw.text((40, max_b - 60), title, fill="#1a365d", font=font_title)
    draw.text((40, max_b - 32), subtitle, fill="#4a5568", font=font_sub)

    # Relations first (behind boxes)
    centers = {
        n: (x + w // 2, y + h // 2) for n, (x, y, w, h) in boxes.items()
    }
    for child, parent, label in RELATIONS:
        if child not in centers or parent not in centers:
            continue
        x1, y1 = centers[child]
        x2, y2 = centers[parent]
        draw.line((x1, y1, x2, y2), fill="#718096", width=2)
        mx, my = (x1 + x2) // 2, (y1 + y2) // 2
        draw.text((mx + 4, my - 10), label, fill="#c53030", font=font_badge)

    # Boxes
    for name, (x, y, w, h) in boxes.items():
        draw.rounded_rectangle(
            [x, y, x + w, y + h],
            radius=6,
            fill="white",
            outline="#2c5282",
            width=2,
        )
        draw.rectangle([x, y, x + w, y + hdr_h], fill="#2b6cb0", outline="#2c5282")
        draw.text((x + pad_x, y + 6), name, fill="white", font=font_hdr)
        cy = y + hdr_h + 4
        for badge, col in tables[name]:
            color = "#1a202c"
            prefix = ""
            if badge.startswith("PK"):
                color = "#744210"
                prefix = "🔑 "
            elif badge.startswith("FK") or badge == "FK":
                color = "#276749"
                prefix = "🔗 "
            elif badge == "UQ":
                color = "#6b46c1"
                prefix = "★ "
            text = f"{prefix}{col}"
            if badge and not badge.startswith("PK") and badge not in ("FK", "UQ") and "FK" in badge:
                text = f"🔗 {col}"
            draw.text((x + pad_x, cy), text, fill=color, font=font_row)
            cy += row_h

    img.save(outfile, "PNG")
    return outfile


def make_zip(files: list[Path]) -> Path:
    zip_path = ROOT / ZIP_NAME
    if zip_path.exists():
        zip_path.unlink()
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for f in files:
            zf.write(f, arcname=f.name)
    return zip_path


def main() -> None:
    pdf = make_pdf()
    print(f"PDF: {pdf} ({pdf.stat().st_size} bytes)")

    logico = draw_er_diagram(
        LOGICAL_TABLES,
        "Modelo Lógico — EPS Institutos Técnicos",
        ROOT / "ModeloLogico.png",
        f"{STUDENT} | Carné {CARNET} | PK/FK/atributos (sin énfasis en tipos Oracle)",
    )
    print(f"Logico: {logico} ({logico.stat().st_size} bytes)")

    rel = draw_er_diagram(
        RELATIONAL_TABLES,
        "Modelo Relacional — EPS Institutos Técnicos",
        ROOT / "ModeloRelacional.png",
        f"{STUDENT} | Carné {CARNET} | Tablas Oracle con tipos de dato",
    )
    print(f"Relacional: {rel} ({rel.stat().st_size} bytes)")

    conceptual = ROOT / "ModeloConceptual.png"
    ddl = ROOT / "DDL.sql"
    required = [pdf, conceptual, logico, rel, ddl]
    for r in required:
        if not r.exists():
            raise FileNotFoundError(r)

    z = make_zip(required)
    print(f"ZIP: {z} ({z.stat().st_size} bytes)")
    with zipfile.ZipFile(z, "r") as zf:
        print("Contenido ZIP:")
        for n in zf.namelist():
            print(f"  - {n}")


if __name__ == "__main__":
    main()
