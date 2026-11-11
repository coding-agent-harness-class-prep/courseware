# Slide Toolchain

Containerized pipeline that turns the Markdown slide decks in [`../md`](../md)
into PowerPoint and PDF using [Marp](https://marp.app/). Everything runs inside a
small Linux container, so the exact same toolchain works on macOS, Windows, and
Linux with no local installs beyond a container engine.

```
md/*.md  ──preprocess.mjs──►  Marp Markdown  ──marp──►  pptx/*.pptx + pdf/*.pdf  ──pdfunite──►  pdf/…-All-Slides.pdf
```

The decks are authored in a clean, tool-agnostic convention (YAML front matter,
`#`/`##` headings, no `---` rules — see below). At build time `preprocess.mjs`
converts each deck into Marp-ready Markdown, and Marp renders it with the
[`courseware.css`](courseware.css) theme. Authors never write Marp scaffolding by
hand.

## Prerequisites

- [podman](https://podman.io/) (default) **or** Docker.
  - On Windows/macOS, start the machine once: `podman machine init` then
    `podman machine start` (only needed the first time).
- Nothing else — Node, Marp, a headless Chrome, and poppler live inside the image.

## Usage

From this `utils/` folder:

**macOS / Linux**

```bash
./convert.sh              # build the image (first run) + convert all decks
./convert.sh --no-build   # skip the build, just re-convert
```

**Windows (PowerShell 7+)**

```powershell
.\convert.ps1             # build the image (first run) + convert all decks
.\convert.ps1 -NoBuild    # skip the build, just re-convert
```

**Use Docker instead of podman**

```bash
CONTAINER_ENGINE=docker ./convert.sh
```
```powershell
$env:CONTAINER_ENGINE = 'docker'; .\convert.ps1
```

Outputs land in [`../pptx`](../pptx) and [`../pdf`](../pdf). The merged deck is
`../pdf/GitHub-Copilot-as-a-Coding-Agent-Harness-All-Slides.pdf`.

> The `.pptx` files are **image-based** (each slide is rendered as a picture).
> That is expected — the generated decks are for projecting, not hand-editing.
> The PDF is the primary deliverable.

## Files

| File | Role |
|------|------|
| `Containerfile` | Defines the image: the official Marp CLI image + poppler-utils + fonts. |
| `entrypoint.sh` | Runs **inside** the container: preprocess → Marp (pptx + pdf) → merge. |
| `preprocess.mjs` | Converts an authored deck into Marp-ready Markdown (front matter, slide breaks, section/title classes). Sets the course-name footer via the `COURSE` constant. |
| `courseware.css` | The Marp theme — professional look + bordered code/terminal blocks. |
| `convert.sh` | Host wrapper for macOS/Linux: builds the image and runs the container. |
| `convert.ps1` | Host wrapper for Windows. |
| `.gitattributes` | Forces LF endings so the container scripts run under Linux. |

## Adding or editing a deck

1. Add/edit a `NN-Module-Name-Slides.md` in [`../md`](../md) — one deck per docs
   module, sorted in module order (`00-Welcome-Slides.md` …
   `05-Conclusion-Slides.md`). The decks mirror the
   [docs modules](../../docs/README.md) and the [course outline](../../outline/).
2. Re-run `./convert.sh` (or `.\convert.ps1`).

The pipeline is file-driven: every `*.md` in `md/` is converted, and the PDFs
are merged in filename (module-number) order, so no script edits are needed.

### Slide Markdown conventions

Decks are authored in a plain, readable convention that `preprocess.mjs` maps to Marp:

- A YAML block at the top (`title`, `subtitle`, `author`) becomes the **title slide**.
- `#` headings are **section-divider** slides (title only, rendered on a dark background).
- `##` headings start a **content** slide; bullets/code/tables under it are the body.
- **No `---` rules** — headings drive the slide breaks. The preprocessor inserts
  the Marp `---` separators for you and is fence-aware, so a `#` comment *inside*
  a ```` ``` ```` code block is never mistaken for a heading.
- **Diagrams are allowed, one per slide.** Reference the PNG by relative path —
  `![Alt text](../../diagrams/png/NN-slug.png)`. `preprocess.mjs` reads the file
  from the `diagrams/` volume mounted at `/diagrams` and inlines it as a base64
  `data:` URI, so the path resolves even though Marp runs against a copy in a
  temp directory, and the generated `.pptx` stays self-contained. A **missing
  diagram fails the build** on purpose: Marp renders a broken image silently.
  Give a diagram its own `##` slide with **no bullets** — the theme caps an image
  at 470 px tall, which is the whole body budget.

Keep bullets terse and code blocks reasonably short. **Marp does not shrink
content to fit** — anything taller than the slide is clipped, silently, with no
build warning. Budget the *whole body*: roughly **16 rendered lines**, counting
every bullet, every code line, and every table row together (a bullet long enough
to wrap costs two). If a slide would overflow, split it into a `Title (1)` /
`Title (2)` pair.

A clipped slide looks fine in the Markdown, so don't rely on reading the source.
After regenerating, run the automated check — it reads the PDFs in
[`../pdf/`](../pdf/) and fails on any page that renders fewer lines than its
source:

```powershell
cd ..\..\validations
npm install          # first time only
npm run test:slides
```

## Theming

The look is controlled entirely by [`courseware.css`](courseware.css), read from
this folder at build time (no image rebuild needed to tweak it — just re-run
`convert`). Highlights:

- Dark title and section-divider slides; light content slides with an accent
  underline under each heading and a course-name footer + slide number.
- **Code blocks** render as bordered boxes in a smaller monospace font. Shell /
  terminal fences (```` ```bash ````, `sh`, `console`, `powershell`, …) render on
  a dark "terminal" background; other languages render light.
- Fira Code **ligatures are disabled** so code operators (`=>`, `==`,
  `!==`, `??`) render exactly as typed — important for a teaching deck.

To change fonts or colors, edit the CSS variables at the top of the file. To
change the footer course name, edit the `COURSE` constant in `preprocess.mjs`;
to change the merged-PDF filename, edit `COMBINED_NAME` in `entrypoint.sh`.

## Troubleshooting

- **`podman` not found / machine not running** — run `podman machine start`.
- **Permission denied on the volume (SELinux Linux hosts)** — add `:Z` to the
  volume mount in `convert.sh` (`-v "$SLIDES_DIR":/work:Z`).
- **A code slide is clipped at the bottom** — the slide has too much content;
  split it into two `##` slides (Marp does not auto-shrink).
- **Fonts look off in the PDF** — add more font packages to the `Containerfile`
  (e.g. `fonts-noto`) and rebuild.
