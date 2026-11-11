# CLAUDE.md

Claude Code reads only `CLAUDE.md`, so this file imports the shared, tool-agnostic guide. The real,
authoritative content lives in `AGENTS.md` at the repo root — the import below pulls it in.

`AGENTS.md` is **generated** from `AGENTS.course.md` (this course's specifics) + `standards/AGENTS.base.md`
(shared cross-course conventions) by `standards/utils/assemble.*`. Edit those sources and re-run the
assembler; never hand-edit `AGENTS.md`. This file holds only that import and the Claude-specific rules
below.

## Branches

Work directly on `main`. Don't create a new branch or a worktree unless the user explicitly asks for one.
This holds even before a large change, and it overrides any default habit or tool guidance that says to
branch first. If a task seems to need a branch, ask before creating it.

@AGENTS.md
