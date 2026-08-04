# HTML Report Format

The report is a single self-contained HTML file. Tailwind and Mermaid both come from CDNs. Mermaid handles graph-shaped diagrams reliably; hand-built divs and inline SVG handle the more editorial visuals (timelines, hierarchies, comparisons). Mix the two — don't lean on Mermaid for everything, it'll start to look generic.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>{{report title}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         dashed lines, hand-drawn-feeling arrow heads, etc. */
      .seam { stroke-dasharray: 4 4; }
      .highlight { stroke: #dc2626; }
      .primary { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="items" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Report title, date, and a compact legend for any visual conventions used in the diagrams. No introduction paragraph — straight into the content.

## Card

The diagrams carry the weight. Prose is sparse and plain.

Each plan item is one `<article>`:

- **Title** — short, names the item
- **Badge row** — status, category, or priority. Pick colours: emerald for positive/go, amber for caution/explore, slate for neutral/speculative
- **Diagram** — the centrepiece. See patterns below
- **Detail** — bullets over paragraphs. ≤6 words per bullet where possible

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the content. Mix them. Don't make every diagram look the same — variety is part of the point.

### Mermaid graph (the workhorse for dependencies / flow)

Use a Mermaid `flowchart` or `graph` when the point is "X leads to Y leads to Z." Wrap it in a Tailwind-styled card so it doesn't feel parachuted in. Style with classDef to colour key paths or highlights. Sequence diagrams work well for "before: N steps; after: 1."

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[Step 1] --> B[Step 2]
      B --> C[Step 3]
      C -.optional.-> D[Step 4]
      classDef highlight stroke:#dc2626,stroke-width:2px;
      class C highlight
  </pre>
</div>
```

### Hand-built boxes-and-arrows (when Mermaid's layout fights you)

Modules as `<div>`s with borders and labels. Arrows as inline SVG `<line>` or `<path>` elements positioned absolutely over a relative container. Reach for this when you want precise control over layout.

### Timeline (good for sequential plans)

Horizontal or vertical timeline with numbered steps. Use Tailwind's flexbox and border utilities. Before: scattered steps. After: clear sequence with dependencies.

### Hierarchy (good for breakdowns)

Nested boxes or tree structure. Parent box contains child boxes. Use indentation, borders, and background colors to show depth.

### Comparison (good for alternatives)

Side-by-side cards or columns. Each alternative gets equal visual weight. Use badges to show pros/cons or status.

## Style guidance

- Lean editorial, not corporate-dashboard. Generous whitespace. Serif optional for headings (`font-serif` works well with stone/slate).
- Colour sparingly: one accent (emerald or indigo) plus red for highlights and amber for warnings.
- Keep diagrams ~320px tall so comparisons sit comfortably side by side without scrolling.
- Use `text-xs uppercase tracking-wider` for labels inside diagrams — they should read as schematic, not as UI.
- The only scripts are the Tailwind CDN and the Mermaid ESM import. The report is otherwise static — no app code, no interactivity beyond Mermaid's own rendering.

## Top recommendation section

One larger card. Item name, one sentence on why, anchor link to its card. That's it.

## Tone

Plain English, concise. Concision is not an excuse to drift into vagueness.

No hedging, no throat-clearing, no "it's worth noting that…". If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it.
