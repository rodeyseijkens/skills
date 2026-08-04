---
name: html-report
description: Turn a plan into a visual HTML report
disable-model-invocation: true
---

# HTML Report

Render a plan as a single self-contained HTML file — Tailwind and Mermaid from CDNs, no build step, no dependencies.

## Process

### 1. Parse the plan

Identify the plan's structure:

- Sequential steps → timeline or numbered flow
- Alternatives or options → comparison cards
- Hierarchical breakdown → tree or nested sections
- Mixed → combine patterns

Extract the key elements: titles, descriptions, relationships, status or priority.

**Completion:** structure type identified, key elements listed.

### 2. Design the visualization

For each major element, choose:

- Card layout — what goes in each card (title, badges, diagram, bullets)
- Diagram type — Mermaid for graphs/flows/sequences, hand-built divs/SVG for editorial visuals
- Color scheme — emerald for go/positive, amber for caution, slate for neutral, red for warnings

**Completion:** visualization approach decided for each element.

### 3. Render the HTML

Write a self-contained HTML file following [HTML-REPORT.md](HTML-REPORT.md) for the scaffold, diagram patterns, and style guidance.

Adapt the card structure to the plan's content. The default card:

- **Title** — short, names the item
- **Badge row** — status, category, or priority
- **Diagram** — the centrepiece; pick the pattern that fits
- **Detail** — sparse prose, bullets over paragraphs

If the plan has a recommended item, end with a **Top recommendation** section: one larger card, one sentence on why, anchor link to its card.

Write to the OS temp directory: resolve from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows). Name the file `report-<timestamp>.html`.

**Completion:** HTML file written, self-contained, renders correctly.

### 4. Open the report

Open the file for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

**Completion:** file opened, absolute path communicated.
