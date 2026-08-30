---
name: read-pdf
description: "Read, extract text, perform OCR, inspect images, or analyze PDF documents. Use whenever you need to read or extract content from a PDF file."
---

# PDF Reader

Use the bundled PDF utility script to extract text, run OCR, inspect metadata, or render pages as images:

```bash
# Resolve path relative to this skill directory:
<skill-dir>/scripts/read-pdf <command> <path-to-pdf> [options]
```

## Commands & Usage

### 1. Extract Text (Fast / Native PDFKit)
Extracts selectable / embedded text layer from all pages or specific page range:

```bash
# All pages
<skill-dir>/scripts/read-pdf text document.pdf

# Single page or page range (1-indexed)
<skill-dir>/scripts/read-pdf text document.pdf --page 1
<skill-dir>/scripts/read-pdf text document.pdf --page 1-3
```

### 2. OCR (macOS Vision Framework)
Use when the document is scanned or text is missing/garbled in the text layer:

```bash
# Perform OCR on entire document or specific page(s)
<skill-dir>/scripts/read-pdf ocr document.pdf --page 1
```

### 3. Visual Inspection (Render Pages to Images)
Renders pages as PNG images into `/tmp` so they can be inspected with Pi's `read` tool (useful for layouts, signatures, drawings, tables):

```bash
# Render page(s) to /tmp
<skill-dir>/scripts/read-pdf render document.pdf --page 1 --out /tmp
```
Then call `read(path: "/tmp/<filename>_page_1.png")` to visually view the rendered page.

### 4. Document Info & Metadata
Displays total page count, document attributes, and page dimensions:

```bash
<skill-dir>/scripts/read-pdf info document.pdf
```

## Recommended Workflow

1. For general text reading: run `text <file>`.
2. If text is missing or poor quality: run `ocr <file>`.
3. If layout, signatures, handwritten notes, or visual elements need inspection: run `render <file> --page <n>` followed by Pi's `read` tool on the generated image.
