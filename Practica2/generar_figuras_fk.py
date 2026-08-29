# -*- coding: utf-8 -*-
"""Figuras del orden de carga e integridad referencial (informe académico)."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parent / "capturas"
OUT.mkdir(exist_ok=True)

BG = (250, 251, 253)
INK = (25, 35, 50)
MUTED = (95, 108, 125)
WHITE = (255, 255, 255)
ARROW = (45, 62, 80)

PALETTE = {
    "cat": ((23, 78, 120), (208, 230, 247)),
    "geo": ((14, 110, 92), (209, 242, 227)),
    "org": ((91, 44, 130), (232, 218, 241)),
    "biz": ((154, 96, 12), (253, 235, 208)),
    "trx": ((133, 40, 32), (250, 219, 216)),
    "det": ((40, 55, 71), (232, 236, 239)),
}


def fnt(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    path = "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf"
    alt = "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"
    for p in (path, alt):
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            pass
    return ImageFont.load_default()


class Box:
    def __init__(self, x, y, w, h, name, kind):
        self.x, self.y, self.w, self.h = x, y, w, h
        self.name, self.kind = name, kind

    @property
    def cx(self):
        return self.x + self.w / 2

    @property
    def cy(self):
        return self.y + self.h / 2

    def top(self):
        return (self.cx, self.y)

    def bottom(self):
        return (self.cx, self.y + self.h)

    def left(self):
        return (self.x, self.cy)

    def right(self):
        return (self.x + self.w, self.cy)


def draw_box(d: ImageDraw.ImageDraw, b: Box, font):
    ol, fill = PALETTE[b.kind]
    d.rounded_rectangle((b.x, b.y, b.x + b.w, b.y + b.h), radius=12, fill=fill, outline=ol, width=3)
    lines = b.name.split("\n")
    tb0 = d.textbbox((0, 0), "Ay", font=font)
    lh = tb0[3] - tb0[1] + 2
    total = lh * len(lines)
    y = b.cy - total / 2
    for line in lines:
        tb = d.textbbox((0, 0), line, font=font)
        tw, th = tb[2] - tb[0], tb[3] - tb[1]
        d.text((b.cx - tw / 2, y), line, font=font, fill=ol)
        y += lh


def draw_arrow(d: ImageDraw.ImageDraw, p1, p2):
    x1, y1 = p1
    x2, y2 = p2
    d.line((x1, y1, x2, y2), fill=ARROW, width=3)
    ang = math.atan2(y2 - y1, x2 - x1)
    L, wd = 13, 7
    left = (x2 - L * math.cos(ang) + wd * math.sin(ang), y2 - L * math.sin(ang) - wd * math.cos(ang))
    right = (x2 - L * math.cos(ang) - wd * math.sin(ang), y2 - L * math.sin(ang) + wd * math.cos(ang))
    d.polygon([p2, left, right], fill=ARROW)


def elbow(d, p1, p2, via_y=None):
    """Orthogonal: down/side/down."""
    x1, y1 = p1
    x2, y2 = p2
    if via_y is None:
        via_y = (y1 + y2) / 2
    d.line((x1, y1, x1, via_y), fill=ARROW, width=3)
    d.line((x1, via_y, x2, via_y), fill=ARROW, width=3)
    draw_arrow(d, (x2, via_y), p2)


def make_grafo():
    w, h = 1680, 1080
    img = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(img)
    title = fnt(28, True)
    sub = fnt(16)
    boxf = fnt(13, True)
    colf = fnt(13, True)
    legf = fnt(14)

    d.text((40, 22), "Por qué el orden de importación es estricto", font=title, fill=INK)
    d.text(
        (40, 62),
        "La flecha apunta al hijo. El padre se importa primero; si no, Oracle responde ORA-02291 (parent key not found).",
        font=sub,
        fill=MUTED,
    )

    bw, bh = 250, 56
    # Three columns
    xa, xb, xc = 70, 710, 1360
    d.text((xa, 108), "Ubicación y academia", font=colf, fill=MUTED)
    d.text((xb, 108), "Empresa y oferta", font=colf, fill=MUTED)
    d.text((xc - 40, 108), "Catálogos (sin FK entre sí)", font=colf, fill=MUTED)
    d.text((xc - 40, 620), "Alimentan al núcleo y al detalle", font=colf, fill=MUTED)

    A, B, C = {}, {}, {}
    A["DEPARTAMENTO"] = Box(xa, 150, bw, bh, "DEPARTAMENTO", "geo")
    A["MUNICIPIO"] = Box(xa, 260, bw, bh, "MUNICIPIO", "geo")
    A["ESTUDIANTE"] = Box(xa, 370, bw, bh, "ESTUDIANTE", "org")
    A["INSTITUTO"] = Box(xa + 280, 150, bw, bh, "INSTITUTO", "org")
    A["CATEDRATICO"] = Box(xa + 280, 260, bw, bh, "CATEDRATICO", "org")

    B["SECTOR_ECONOMICO"] = Box(xb, 150, bw, bh, "SECTOR_ECONOMICO", "cat")
    B["EMPRESA"] = Box(xb, 250, bw, bh, "EMPRESA", "biz")
    B["CONTACTO"] = Box(xb, 350, bw, 62, "CONTACTO\nEMPRESARIAL", "biz")
    B["PLAZA"] = Box(xb, 460, bw, bh, "PLAZA", "biz")

    C["ESTADO"] = Box(xc, 660, bw, bh, "ESTADO_COLOCACION", "cat")
    C["TIPO"] = Box(xc, 800, bw, bh, "TIPO_EVALUACION", "cat")
    C["CRITERIO"] = Box(xc, 920, bw, bh, "CRITERIO", "cat")

    COL = Box(710, 660, 250, 60, "COLOCACION", "trx")
    BIT = Box(400, 800, bw, bh, "BITACORA", "trx")
    EVA = Box(1020, 800, bw, bh, "EVALUACION", "trx")
    DET = Box(1020, 920, bw, bh, "DETALLE_EVALUACION", "det")

    for group in (A, B, C):
        for b in group.values():
            draw_box(d, b, boxf)
    for b in (COL, BIT, EVA, DET):
        draw_box(d, b, boxf)

    # Column A
    draw_arrow(d, A["DEPARTAMENTO"].bottom(), A["MUNICIPIO"].top())
    draw_arrow(d, A["MUNICIPIO"].bottom(), A["ESTUDIANTE"].top())
    draw_arrow(d, A["INSTITUTO"].bottom(), A["CATEDRATICO"].top())
    draw_arrow(d, A["INSTITUTO"].bottom(), A["ESTUDIANTE"].right())
    elbow(d, A["ESTUDIANTE"].bottom(), COL.left(), via_y=COL.cy)
    elbow(d, A["CATEDRATICO"].bottom(), COL.left(), via_y=COL.cy + 12)

    # Column B vertical
    draw_arrow(d, B["SECTOR_ECONOMICO"].bottom(), B["EMPRESA"].top())
    draw_arrow(d, B["EMPRESA"].bottom(), B["CONTACTO"].top())
    draw_arrow(d, B["EMPRESA"].bottom(), B["PLAZA"].top())
    draw_arrow(d, B["CONTACTO"].bottom(), B["PLAZA"].top())
    draw_arrow(d, B["PLAZA"].bottom(), COL.top())

    # Catalogs sit next to the child they feed (they do not depend on each other)
    draw_arrow(d, C["ESTADO"].left(), COL.right())
    draw_arrow(d, C["TIPO"].left(), EVA.right())
    draw_arrow(d, C["CRITERIO"].left(), DET.right())

    draw_arrow(d, COL.bottom(), BIT.top())
    draw_arrow(d, COL.bottom(), EVA.top())
    elbow(d, B["CONTACTO"].left(), BIT.top(), via_y=780)
    elbow(d, A["CATEDRATICO"].right(), EVA.left(), via_y=EVA.cy)
    draw_arrow(d, EVA.bottom(), DET.top())

    ly = 1010
    d.line((40, ly - 16, w - 40, ly - 16), fill=(220, 224, 230), width=1)
    items = [
        ("cat", "Catálogo"),
        ("geo", "Ubicación"),
        ("org", "Académico"),
        ("biz", "Empresa y plaza"),
        ("trx", "Transacción"),
        ("det", "Detalle"),
    ]
    x = 40
    for key, label in items:
        ol, fill = PALETTE[key]
        d.rounded_rectangle((x, ly, x + 20, ly + 16), radius=4, fill=fill, outline=ol, width=2)
        d.text((x + 28, ly - 2), label, font=legf, fill=INK)
        x += 200
    d.text((x, ly - 2), "Padre  →  hijo   (importar el padre primero)", font=legf, fill=MUTED)

    img.save(OUT / "fig_grafo_fk.png", "PNG")
    print("grafo", OUT / "fig_grafo_fk.png")


def make_orden():
    w, h = 1580, 980
    img = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(img)
    title = fnt(28, True)
    sub = fnt(15)
    numf = fnt(18, True)
    head = fnt(16, True)
    body = fnt(13)
    tiny = fnt(12)

    d.text((48, 26), "Secuencia de importación utilizada en Oracle SQL Developer", font=title, fill=INK)
    d.text(
        (48, 66),
        "Diez pasos de padres a hijos. PLAZA se carga en el paso 6 aunque el enunciado no la numere: COLOCACION depende de ella.",
        font=sub,
        fill=MUTED,
    )

    steps = [
        ("1", "Catálogos raíz", "SECTOR_ECONOMICO, DEPARTAMENTO, ESTADO_COLOCACION,\nTIPO_EVALUACION, CRITERIO, INSTITUTO", "Sin FK. Cualquier orden entre ellas.", "cat"),
        ("2", "MUNICIPIO", "Depende de DEPARTAMENTO", "id_departamento debe existir.", "geo"),
        ("3", "EMPRESA", "Depende de SECTOR_ECONOMICO", "id_sector debe existir.", "biz"),
        ("4", "CATEDRATICO", "Depende de INSTITUTO", "id_instituto debe existir.", "org"),
        ("5", "CONTACTO_EMPRESARIAL", "Depende de EMPRESA", "Evita contactos huérfanos.", "biz"),
        ("6", "ESTUDIANTE y PLAZA", "Estudiante: MUNICIPIO e INSTITUTO.\nPlaza: EMPRESA y CONTACTO.", "Paso omitido en el §3.3 del enunciado, obligatorio.", "org"),
        ("7", "COLOCACION", "Estudiante, plaza, catedrático y estado.", "Cuatro padres a la vez.", "trx"),
        ("8", "BITACORA", "COLOCACION y CONTACTO_EMPRESARIAL", "id_contacto_validador.", "trx"),
        ("9", "EVALUACION", "COLOCACION, CATEDRATICO y TIPO_EVALUACION", "Parcial o Final.", "trx"),
        ("10", "DETALLE_EVALUACION", "EVALUACION y CRITERIO", "Puntuación 1 a 5. Última tabla.", "det"),
    ]

    col_w, box_h = 710, 148
    for i, (num, tit, dep, why, kind) in enumerate(steps):
        col, row = i % 2, i // 2
        x = 48 + col * (col_w + 36)
        y = 110 + row * (box_h + 16)
        ol, fill = PALETTE[kind]
        d.rounded_rectangle((x, y, x + col_w, y + box_h), radius=16, fill=fill, outline=ol, width=3)
        d.ellipse((x + 16, y + 18, x + 64, y + 66), fill=ol)
        tb = d.textbbox((0, 0), num, font=numf)
        tw, th = tb[2] - tb[0], tb[3] - tb[1]
        d.text((x + 40 - tw / 2, y + 42 - th / 2), num, font=numf, fill=WHITE)
        d.text((x + 80, y + 20), tit, font=head, fill=ol)
        d.text((x + 80, y + 52), dep, font=body, fill=INK)
        d.text((x + 80, y + 112), why, font=tiny, fill=MUTED)

    img.save(OUT / "fig_orden_carga.png", "PNG")
    print("orden", OUT / "fig_orden_carga.png")


if __name__ == "__main__":
    make_grafo()
    make_orden()
