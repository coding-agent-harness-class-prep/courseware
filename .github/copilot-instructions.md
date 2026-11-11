# GitHub Copilot Instructions

The full, authoritative guide for this repository is **[`AGENTS.md`](../AGENTS.md)** at the repo root.
GitHub Copilot reads `AGENTS.md` natively; this file is a thin pointer kept for setups that look here
first. Read `AGENTS.md` before making non-trivial changes.

`AGENTS.md` is **generated** from two sources:

- `AGENTS.course.md` — values specific to *GitHub Copilot as a Coding-Agent Harness*.
- `standards/AGENTS.base.md` — the shared, cross-course conventions (a submodule-ready folder).

Edit those sources, then run `standards/utils/assemble.ps1` (or `assemble.sh`) to rebuild `AGENTS.md`.
Never hand-edit `AGENTS.md`.
