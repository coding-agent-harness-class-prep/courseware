# Diagrams

These are the **ten generated figures** the course embeds. Each one is built with the
**diagram-builder** MCP tool and committed here with its source, so when Copilot changes (and it changes
often) you can open the figure, amend it, and render it again instead of redrawing it from scratch.

The webinar is taught live, and the instructor will often sketch these ideas while talking. The committed
figures are the reference versions, so students have something clean to come back to after the session.

## What is in this folder

```
diagrams/
├── svg/    ⭐ SOURCE: the diagram-builder files (they keep the embedded model; this is what you edit)
├── png/    GENERATED: rendered at scale 2; this is what docs and slides embed
└── pdf/    GENERATED: vector, for printing and handouts
```

All three formats share one `NN-slug` stem. Numbering runs `01`–`10` in **module order**, so the number
tells you roughly where in the course a figure belongs. Don't hand-edit a PNG or PDF; change the SVG
through the tool and render it again.

## The diagrams

| # | Diagram | Module | What it shows |
|---|---------|--------|---------------|
| 01 | [Model vs. harness](./png/01-model-vs-harness.png) | 1 | The agent loop: the harness assembles context, offers tools, asks for approval, and keeps session state, while the model only picks the next step |
| 02 | [One harness, four surfaces](./png/02-one-harness-four-surfaces.png) | 1 | VS Code, the Copilot CLI, the Copilot app, and GitHub.com sitting on one Copilot harness, which reads the same instructions, custom agents, and MCP configuration |
| 03 | [The capability ladder](./png/03-capability-ladder.png) | 1 | Chat → agent mode → Copilot CLI → Copilot cloud agent, with where each one runs and how much autonomy it has |
| 04 | [Context assembly](./png/04-context-assembly.png) | 1 | What goes into one request: instruction files, attached context (`#file`, the selection, `#codebase`), tool results, history, and your prompt |
| 05 | [The agent mode loop](./png/05-agent-mode-loop.png) | 2 | Plan → tool call → approval gate → result back into context → next step, or done |
| 06 | [How instruction files combine](./png/06-instruction-files.png) | 2 | `.github/copilot-instructions.md` (always), `*.instructions.md` (when `applyTo` matches), and the nearest `AGENTS.md`, combined into one set |
| 07 | [MCP architecture](./png/07-mcp-architecture.png) | 2 | The agent and the harness's MCP client, talking to the remote GitHub MCP server over HTTP and to an internal server over stdio |
| 08 | [The cloud agent flow](./png/08-cloud-agent-flow.png) | 3 | Issue → assign to Copilot → GitHub Actions environment (`copilot-setup-steps.yml`) → work and validation (CodeQL, secret scanning, dependency check, Copilot code review) → draft PR → human review |
| 09 | [Copilot CLI permissions](./png/09-cli-permissions.png) | 4 | A tool request checked against deny rules, then allow rules, then asking you, before it runs in the sandbox (once `/sandbox enable` is on) |
| 10 | [CLI and cloud handoffs](./png/10-cli-cloud-handoff.png) | 4 | A terminal session sent to the cloud agent with `/delegate` (or `&`), and pulled back with "Continue in Copilot CLI" or `--resume` |

Modules 1 through 4 each have at least one diagram. The conclusion doesn't have one of its own.

## Where they appear

Each diagram is embedded, as the **PNG**, in its module's doc chapter at the section it explains, and on
a slide of its own in that module's deck; most also appear in the module's demo or activity README. All
of those files sit two levels below `courseware/`, so one relative path works from any of them:

```markdown
![Alt text describing what the diagram shows](../../diagrams/png/NN-slug.png)
```

Always embed the PNG, never the SVG. The slides container has only Fira Code, Liberation, and DejaVu
installed, so the diagram-builder's IBM Plex Sans and JetBrains Mono text would fall back to different
metrics there and overflow its own boxes.

The slides pipeline inlines each figure at build time: `slides/utils/preprocess.mjs` reads the PNG from
the `diagrams/` folder (mounted into the container) and rewrites the image line as a base64 `data:` URI.
A missing or misspelled diagram fails the build on purpose, because Marp would otherwise leave a blank
space and exit cleanly.

## Adding or changing a diagram

1. **Draw it with the diagram-builder MCP tool.** The page is fixed at US Legal landscape, 1008 × 612 pt,
   so design for a wide, shallow figure. Build it in one `apply_ops` call where you can, and use the
   palette names (blue, indigo, teal, and orange first) rather than hex values.
2. **Look at what you made.** `render` returns a PNG, so check it for clipped connector labels, text
   spilling out of boxes, and crossing arrows. A connector label needs roughly 90 pt between its two
   shapes or it'll be clipped, and the tool won't warn you. Connectors draw underneath shapes, so give a
   container box `fill: "none"` if anything connects inside it.
3. **Render the outputs.** Keep the `.svg` the tool wrote in `svg/` (don't overwrite it with a "clean"
   SVG export, which drops the model), then render `png/NN-slug.png` at `scale: 2` and
   `pdf/NN-slug.pdf`.
4. **Register it** in the table above and in the **Diagram** column of
   [`instructor/COURSE-MAP.md`](../instructor/COURSE-MAP.md), and update that file's counts table.
5. **Re-run the slides pipeline** if a deck embeds it. Run `slides/utils/convert.ps1` (or
   `convert.sh`), since the decks only pick up a changed PNG when they're rebuilt.

Keep each figure sparse. If a diagram needs a legend, it's doing too much, and it's probably two
diagrams.
