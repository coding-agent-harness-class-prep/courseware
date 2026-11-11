# Shared courseware standards

Reusable, cross-course agent instructions for the training program. This folder is designed to be a
**git submodule** shared by every course repo, so the common conventions live in one place.

## What's here

| File | Role |
|------|------|
| `AGENTS.base.md` | ⭐ The shared **[PATTERN]** conventions (how courses are structured, authoring templates, pipelines, working rules). |
| `utils/assemble.sh` / `utils/assemble.ps1` | Build a repo's `AGENTS.md` from `AGENTS.base.md` + the repo's `AGENTS.course.md`. |

## How instructions are wired (per course repo)

```
<repo>/AGENTS.course.md          ⭐ course-specific values (hand-edited)
<repo>/standards/AGENTS.base.md  ⭐ shared conventions (hand-edited; this submodule)
        │
        └── standards/utils/assemble  ──►  <repo>/AGENTS.md   (GENERATED)
                                              ▲
                 CLAUDE.md  = `@AGENTS.md`  ──┘   (Claude Code imports it)
                 .github/copilot-instructions.md → points at AGENTS.md
                 Codex · Grok · Cursor · Gemini … read AGENTS.md natively
```

`AGENTS.md` is the single source of truth that every tool reads. It is **generated** — never hand-edit
it. Edit `AGENTS.course.md` (course specifics) or `AGENTS.base.md` (shared), then re-run the assembler:

```bash
./standards/utils/assemble.sh
```
```powershell
.\standards\utils\assemble.ps1
```

Commit the regenerated `AGENTS.md` so the tools that don't support file includes (Codex, Copilot, Grok)
see the full, current instructions.

## Promoting `standards/` to a shared submodule

Right now `standards/` is a plain folder in this repo so everything works standalone. To share it across
courses:

1. Create a new repo (e.g. `courseware-standards`) containing `AGENTS.base.md` and `utils/`.
2. In each course repo, replace the local folder with the submodule:
   ```bash
   git rm -r standards
   git commit -m "Remove local standards (moving to submodule)"
   git submodule add <url-of-courseware-standards> standards
   git commit -m "Add shared courseware standards as a submodule"
   ```
3. Regenerate: `./standards/utils/assemble.sh` (or `.ps1`), then commit the updated `AGENTS.md`.

To pull the latest shared standards into a course later: `git submodule update --remote standards`, then
re-run the assembler and commit.

> Anyone cloning a course repo that uses the submodule should clone with
> `git clone --recurse-submodules …`, or run `git submodule update --init` after cloning, before running
> the assembler.
