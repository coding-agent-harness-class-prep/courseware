# Outline toolchain

Generates the course-outline **PDF** from its Markdown source.

```
outline/
├── md/    ⭐ SOURCE — GitHubCopilotAsACodingAgentHarness_Outline.md (hand-edited)
├── pdf/   GENERATED — the PDF the repo README links to (do not hand-edit)
└── utils/ this toolchain
```

## Pipeline

`md/*.md` → *(build.mjs + [marked](https://marked.js.org/))* → styled HTML →
*(headless Chrome)* → `pdf/*.pdf`

It's **file-driven**: every `*.md` in `md/` is converted to a same-named PDF in `pdf/`. Styling lives
in [`outline.css`](outline.css) (edit there — no image rebuild needed for a style tweak *if* you
mount and re-run; a fresh style baked into the image requires a rebuild). The container reuses the same
base image as the slide toolchain (`marpteam/marp-cli`), so it shares that image's bundled Node.js and
headless Chrome.

## Regenerate

Requires a running container engine (`podman machine start` on Windows/macOS the first time).

```bash
./convert.sh              # macOS/Linux: build image (first run) + convert
./convert.sh --no-build   # re-convert only
```

```powershell
.\convert.ps1             # Windows (PowerShell 7+): build image (first run) + convert
.\convert.ps1 -NoBuild    # re-convert only
```

Docker instead of podman: set `CONTAINER_ENGINE=docker` (bash) or
`$env:CONTAINER_ENGINE = 'docker'` (PowerShell) before running.

## Files

| File | Role |
|------|------|
| `Containerfile` | Builds `copilot-harness-outline:latest` (marp-cli base + `marked` + fonts). |
| `entrypoint.sh` | Runs inside the container: for each `md/*.md`, build HTML then print PDF. |
| `build.mjs` | Markdown → styled, self-contained HTML (strips YAML front matter). |
| `outline.css` | Print styles for the PDF. |
| `convert.sh` / `convert.ps1` | Host wrappers (build image + run container). |
