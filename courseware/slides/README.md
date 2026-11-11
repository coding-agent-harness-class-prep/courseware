# Slides

Reference decks for the session: a welcome deck, one deck per module, and a conclusion deck. They
aren't presented in class, where each module is taught through its live demo. Students review them
during an activity (each activity links its module's deck) or afterward. Each module deck ends with a
**Live demo** slide (the demo trail in that module's demo README) and a **Your turn** slide (the
activity). The decks mirror the [docs modules](../docs/README.md) and the
[course outline](../outline/README.md).

## What's in this folder

```
slides/
├── md/     ⭐ SOURCE — one authored deck per outline section, plus the welcome deck (hand-edited)
├── pptx/   GENERATED — image-based PowerPoint, one per deck (do not hand-edit)
├── pdf/    GENERATED — one PDF per deck + a merged all-decks PDF (do not hand-edit)
└── utils/  Containerized md → pptx → pdf toolchain (see utils/README.md)
```

**Edit the Markdown in [`md/`](./md/) and regenerate. Never hand-edit the `pptx/` or `pdf/`
outputs.** The decks are authored in a plain, tool-agnostic convention (YAML front matter for the
title slide; `#` = section-divider slide, `##` = content slide; no `---` rules) that the pipeline's
`preprocess.mjs` maps to Marp. A slide may embed one diagram from
[`../diagrams/png/`](../diagrams/README.md), on a slide of its own with no bullets beside it. A slide's
body must fit in about 16 rendered lines; Marp clips anything taller without warning, and
`validations/unit/slides.test.js` checks the generated PDFs for exactly that.

## The decks

Named to sort in session order. The pipeline merges the per-deck PDFs in filename order.

| # | Deck | Outline section |
|---|------|-----------------|
| 00 | [Welcome](./md/00-Welcome-Slides.md) | Course summary, agenda, environment, practice repo |
| 01 | [The Copilot Harness and Chat in VS Code](./md/01-Copilot-Harness-and-Chat-Slides.md) | Module 1 |
| 02 | [Agent Mode in VS Code with Instructions, Custom Agents, and MCP](./md/02-Agent-Mode-Instructions-Agents-MCP-Slides.md) | Module 2 |
| 03 | [GitHub.com, the Cloud Agent and Code Review](./md/03-Cloud-Agent-and-Code-Review-Slides.md) | Module 3 |
| 04 | [The GitHub Copilot CLI in the Terminal](./md/04-Copilot-CLI-Slides.md) | Module 4 |
| 05 | [Copilot, OpenCode, and Kiro Side by Side](./md/05-Conclusion-Slides.md) | Conclusion |

The merged deck is
[`pdf/GitHub-Copilot-as-a-Coding-Agent-Harness-All-Slides.pdf`](./pdf/GitHub-Copilot-as-a-Coding-Agent-Harness-All-Slides.pdf).

## Regenerate

Run the containerized toolchain from [`utils/`](./utils/). It needs a running container engine (podman
by default, or Docker with `CONTAINER_ENGINE=docker`):

```powershell
.\convert.ps1             # Windows (PowerShell 7+): build image (first run) + convert
.\convert.ps1 -NoBuild    # re-convert only
$env:CONTAINER_ENGINE = 'docker'; .\convert.ps1   # use Docker instead of podman
```

```bash
./convert.sh              # macOS/Linux: build image (first run) + convert all decks
./convert.sh --no-build   # re-convert only
```

Then check nothing was clipped: `cd ..\validations; npm run test:slides`.

The merge step picks up every PDF in `pdf/`, so when you delete or rename a deck, delete its old PDF and
PPTX too.

## Related

- [Course outline](../outline/README.md) — the sections these decks follow
- [Documentation](../docs/README.md) — the reference chapters behind the lectures
- [Demos](../demos/README.md) — what the instructor runs after each deck's slides
- [Activities](../activities/README.md) — what students do after each demo
