# -*- coding: utf-8 -*-
"""Genera Manual.pdf a partir de Manual.md y las capturas."""
from __future__ import annotations

import re
from pathlib import Path

from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    Image,
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    Preformatted,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)
from reportlab.lib import colors

ROOT = Path(__file__).resolve().parent
MD = ROOT / "Manual.md"
OUT = ROOT / "Manual.pdf"
CAP = ROOT / "capturas"


def styles():
    s = getSampleStyleSheet()
    s.add(ParagraphStyle(name="H1", parent=s["Heading1"], fontName="Times-Bold", fontSize=14, leading=18, spaceBefore=14, spaceAfter=8))
    s.add(ParagraphStyle(name="H2", parent=s["Heading2"], fontName="Times-Bold", fontSize=12, leading=16, spaceBefore=12, spaceAfter=6))
    s.add(ParagraphStyle(name="H3", parent=s["Heading3"], fontName="Times-Bold", fontSize=11, leading=14, spaceBefore=10, spaceAfter=5))
    s.add(ParagraphStyle(name="Body", parent=s["Normal"], fontName="Times-Roman", fontSize=11, leading=15, alignment=TA_JUSTIFY, spaceAfter=7))
    s.add(ParagraphStyle(name="Center", parent=s["Normal"], fontName="Times-Bold", fontSize=13, leading=17, alignment=TA_CENTER, spaceAfter=6))
    s.add(ParagraphStyle(name="Caption", parent=s["Normal"], fontName="Times-Italic", fontSize=9, leading=12, alignment=TA_CENTER, spaceBefore=3, spaceAfter=10))
    s.add(ParagraphStyle(name="CodeES", parent=s["Code"], fontName="Courier", fontSize=7.5, leading=10, leftIndent=6, spaceBefore=4, spaceAfter=8))
    s.add(ParagraphStyle(name="Cell", parent=s["Normal"], fontName="Times-Roman", fontSize=8, leading=10))
    return s


def esc(t: str) -> str:
    t = t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    t = re.sub(r"`([^`]+)`", r"<font face='Courier' size='9'>\1</font>", t)
    t = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", t)
    t = re.sub(r"\*([^*]+)\*", r"<i>\1</i>", t)
    return t


def fit_image(path: Path, max_w=6.4 * inch, max_h=4.2 * inch):
    img = Image(str(path))
    img.hAlign = "CENTER"
    w, h = img.imageWidth, img.imageHeight
    if w == 0 or h == 0:
        return img
    scale = min(max_w / w, max_h / h, 1)
    img.drawWidth = w * scale
    img.drawHeight = h * scale
    return img


def build():
    st = styles()
    story = []
    lines = MD.read_text(encoding="utf-8").splitlines()
    i = 0
    in_code = False
    code_buf: list[str] = []
    in_table = False
    table_rows: list[list[str]] = []

    def flush_code():
        nonlocal code_buf
        if code_buf:
            story.append(Preformatted("\n".join(code_buf), st["CodeES"]))
            code_buf = []

    def flush_table():
        nonlocal table_rows, in_table
        if not table_rows:
            in_table = False
            return
        data = []
        for row in table_rows:
            data.append([Paragraph(esc(c.strip()), st["Cell"]) for c in row])
        t = Table(data, colWidths=[1.5 * inch] * min(len(data[0]), 4) if data else None)
        t.setStyle(
            TableStyle(
                [
                    ("FONTNAME", (0, 0), (-1, 0), "Times-Bold"),
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#E8EEF7")),
                    ("GRID", (0, 0), (-1, -1), 0.4, colors.grey),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 4),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                    ("TOPPADDING", (0, 0), (-1, -1), 3),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
                ]
            )
        )
        story.append(t)
        story.append(Spacer(1, 8))
        table_rows = []
        in_table = False

    while i < len(lines):
        line = lines[i]
        if line.strip().startswith("```"):
            if in_code:
                flush_code()
                in_code = False
            else:
                flush_table()
                in_code = True
            i += 1
            continue
        if in_code:
            code_buf.append(line)
            i += 1
            continue

        img = re.match(r"!\[([^\]]*)\]\(([^)]+)\)", line.strip())
        if img:
            flush_table()
            rel = img.group(2).replace("/", "\\")
            p = ROOT / rel
            if p.exists():
                story.append(fit_image(p))
            i += 1
            continue

        if line.strip().startswith("*Figura") or (line.strip().startswith("*") and line.strip().endswith("*") and "Figura" in line):
            flush_table()
            story.append(Paragraph(esc(line.strip().strip("*")), st["Caption"]))
            i += 1
            continue

        if line.strip().startswith("|") and "---" not in line:
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if not in_table:
                in_table = True
                table_rows = []
            table_rows.append(cells)
            i += 1
            continue
        if line.strip().startswith("|") and "---" in line:
            i += 1
            continue
        if in_table:
            flush_table()

        if line.startswith("# ") and not line.startswith("##"):
            story.append(Paragraph(esc(line[2:].strip()), st["H1"]))
        elif line.startswith("## "):
            story.append(Paragraph(esc(line[3:].strip()), st["H2"]))
        elif line.startswith("### "):
            story.append(Paragraph(esc(line[4:].strip()), st["H3"]))
        elif line.strip() == "---":
            story.append(Spacer(1, 8))
        elif line.strip().startswith("> "):
            story.append(Paragraph(esc(line.strip()[2:]), st["Body"]))
        elif line.strip().startswith("- ") or line.strip().startswith("1. "):
            story.append(Paragraph("• " + esc(re.sub(r"^(\d+\.|-)\s+", "", line.strip())), st["Body"]))
        elif line.strip() == "":
            story.append(Spacer(1, 4))
        else:
            story.append(Paragraph(esc(line.strip()), st["Body"]))
        i += 1

    flush_code()
    flush_table()

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=letter,
        leftMargin=0.75 * inch,
        rightMargin=0.75 * inch,
        topMargin=0.7 * inch,
        bottomMargin=0.7 * inch,
        title="Manual Practica 2 - 202300689",
        author="Josue Daniel Herrera Cottom",
    )
    doc.build(story)
    print(f"OK {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    build()
