<!--
  SHARED COURSEWARE STANDARDS — the reusable [PATTERN] base for every course in this
  training program. It is combined with a per-course AGENTS.course.md to produce each
  repo's AGENTS.md (run standards/utils/assemble.sh or standards/utils/assemble.ps1).

  Edit CROSS-COURSE conventions here. Edit COURSE-SPECIFIC values in AGENTS.course.md.
  Never edit the generated AGENTS.md directly.

  This base states conventions that hold ACROSS courses and defers concrete structure —
  folder shapes, numbering scheme, how demos and activities relate, theme(s) — to the
  per-course profile. Courses differ: some group docs into module folders, others number
  them flat; some ship one demo per activity, others a single reference app the activities
  build. Read the course profile above for THIS course's specifics; where the profile and
  this base disagree, the profile wins.

  This folder is intended to become a git submodule shared across courses — see
  standards/README.md for how to promote it.
-->

## How the material is organized (the artifact model)

A course in this program is one body of material seen through a few artifact types. **They are
cross-referenced, not independent** — a change to one usually implies a change to others. Not every
course uses every artifact; the course profile says which exist and where they live.

| Artifact | Typical folder | Audience | Purpose |
|----------|----------------|----------|---------|
| **Docs (topics)** | `courseware/docs/` | Student (reference) | The prose "textbook" — one chapter per topic |
| **Slides** | `courseware/slides/md/` | Instructor (projected) | The lecture spine, one deck per outline section |
| **Demos** | `courseware/demos/` | Instructor (performs) | Runnable code shown live — per-activity demos or a single reference app (the profile says which) |
| **Activities** | `courseware/activities/` | Student (does) | Hands-on exercises that apply the docs |
| **Assessments** | `courseware/assessments/` | Both | End-of-module formative checks (one exit ticket per module) |
| **Teaching guide** | `courseware/instructor/` | Instructor | Day-by-day flow — the *itinerary* — *only if the course has one* |
| **Course map** | `courseware/instructor/` | Instructor | The *join table* connecting every artifact to every other — *only if the course has one* |
| **Diagrams** | `courseware/diagrams/` | Both | Generated figures (svg source + png + pdf) embedded by the docs, slides, demos and activities — *only if the course has them* |
| **Setup** | `courseware/setup/` | Student + IT | What to install before day one, plus install scripts — *optional* |
| **Build utils** | `courseware/utils/` | Instructor | Install/build sweep over every project in the repo — *optional* |
| **Validations** | `courseware/validations/` | Instructor + CI | Harness proving every demo and activity solution still runs — *optional* |

### The relationship graph

- **`docs/README.md` is the docs' table of contents.** It lists every chapter in reading order. When
  you add, remove, or renumber a chapter, update it in the same change. Whether chapters are numbered
  flat or grouped into module folders is set by the course profile. Docs are typically **not** referenced
  by number from anywhere else, so renumbering usually touches only the files themselves and this index.
- **`slides/README.md` and `outline/README.md` are the tables of contents for those folders** (parallel
  to `docs/README.md`). `slides/README.md` maps each deck to its outline section; `outline/README.md`
  lists the outline's sections. They describe folder *content* — distinct from the `slides/utils/` and
  `outline/utils/` READMEs, which document the build pipeline. Adding, removing, or renumbering a slide
  deck or an outline section means updating the matching folder README in the same change.
- **Demos and activities teach the same ideas.** *How* they relate is course-specific: some courses pair
  a self-contained demo one-to-one with each activity (same concept, taught on *different content* per
  the profile's themes); others provide a **single reference app** that the activities build up
  incrementally. Follow the course profile — keep whatever pairing and **theme(s)** it names, and don't
  cross themes the profile says to keep separate.
- **Activities may be cumulative, standalone, or a mix** — the course profile says which. **Where a
  cumulative chain exists, each step continues from the previous step's finished state** (whether that is
  a previous activity's `solution/` folder or the shared reference app). **Preserve that chain when
  editing** — a change to an early step ripples forward. Where the profile uses `begin/`/`end/`/`solution/`
  folders, keep `## Stretch goal` sections **additive** — never reflected in `solution/` — so the next
  step's starting point is unaffected.
- **Assessments are keyed to modules, not days.** The `assessments/` suite is one **formative exit
  ticket per module**, indexed by its own `README.md`. Each ticket's questions are grounded in that
  module's docs, so a change to a module's chapters may mean updating its ticket. The number of tickets
  must match the number of modules the profile defines; keep the per-module framing (never "daily/per-day").
  Assessments are for-the-learner-first and **never graded or ranked**.
- **Where a course has a course map, it is the join table — and the single source of that truth.** The
  teaching guide answers *when do I teach this?*; the course map answers *what goes with what?*. Keep the
  cross-artifact table in **one** file and link to it from the other, rather than maintaining two copies
  that drift. A course map should carry a **counts table** (docs, slides, demos, activities, tickets,
  diagrams) so a renumbering that misses a row is caught by arithmetic.
- **Diagrams are generated into the repo, and images are welcome.** A course's drawings are built with the
  **diagram-builder** MCP tool and committed under `diagrams/` in three formats per diagram — `svg/`
  (the editable source the tool reads back), `png/` (what content embeds), and `pdf/` (print/handout).
  Doc chapters, slide decks, and demo/activity READMEs embed the **PNG** by relative path. Because the
  source lives beside the output, a diagram is regenerated rather than redrawn, which is what keeps it
  from going stale. Register every diagram in the `diagrams/` index and in the course map's diagram column.
- **Index tables must agree.** Every index that lists shared material — the root `README.md` outline,
  `docs/README.md`, `activities/README.md`, and (where the course has them) `demos/README.md`,
  `slides/README.md`, `outline/README.md`, `assessments/README.md`, `diagrams/README.md`, the teaching
  guide, and the course map — describes the same material. Treat divergence as a bug. Update only the
  indexes the course actually has.
- **Cross-link demos and activities back to the docs.** Each demo/activity README should end with a
  *Related reading* (or *Reinforces*) link to its paired doc chapter(s); each assessment ticket draws its
  questions from — and can link back to — its module's doc chapters.

## Cross-cutting voice

- **Plain-English, encouraging, example-driven.** Small, runnable code blocks with results shown in
  `// comments`.
- **Write American English.** `color`, `behavior`, `initialize`, `analyze`, `defense`, `catalog`,
  `labeled`, `judgment`. The exceptions are genuine proper nouns (an album or product title), terms
  a specification actually spells that way (the PNG spec's `greyscale` / `truecolour` color types),
  and wire values a running system depends on (`cancelled` as a status enum) — those stay as they are.
- **Contractions are the default, not a concession.** `it's`, `don't`, `you'll`, `that's`, `can't`,
  `won't`, `isn't`. Save the expanded form for the sentence that genuinely leans on the emphasis —
  "this is *not* optional" earns it; "it is a function call" does not.
- **Vary sentence length, and keep paragraphs to a few sentences of mixed length.** Three of these
  habits make prose read like it was generated rather than written, and none of them belong here:
  - the standalone punchy declarative used as a paragraph opener ("Your API runs on your laptop.")
  - the verbless fragment used for rhythm ("Immutable, versioned, shareable." / "Disposable.")
  - the em-dash punchline tail ("…and it fails predictably — which is the whole point.")
  Where one of these turns up, fold the thought into the sentence beside it and let the paragraph
  carry the emphasis instead.
- **Prose before bullets.** A bulleted list is for items that really are parallel — flags, options,
  steps, comparisons. It is not a way to chop an explanation into pieces. In particular, avoid the
  run of bolded one-word lead-ins (`* **Disposable.**` / `* **Size.**`); give each item a real clause,
  or write the passage as a paragraph.
- **Vary how a chapter opens.** Don't reach for the same template every time ("This doc covers X, Y,
  and Z"); a reader working through a module in order notices, and it reads like a form letter.
- **Assume the audience's stated starting point** (see the course profile) — define jargon the first
  time it appears; don't assume knowledge the profile says they lack.
- **Windows-first platform voice** (see *Platform & tooling* below).

## Authoring conventions per artifact

Match the existing template exactly when adding a new file. The quickest and most reliable way to conform
is to **copy the nearest existing sibling and adapt it** — the profile names the concrete scheme, but the
files on disk are the ground truth.

### Doc chapter (`courseware/docs/…`)
- Single H1 title. Prose-first "textbook chapter" with `##`/`###` structure and `---` horizontal rules
  between major sections.
- Many small, focused fenced code blocks; show output/results as `// comments`.
- **No YAML front matter.** Images **are** allowed: embed a diagram's PNG by relative path
  (`![Alt text](../../diagrams/png/NN-slug.png)`) at the section it explains, with a short italic caption
  beneath it. Use one where the idea is structural — a flow, a layering, an ordering — not to decorate
  prose that already reads clearly. Close with a short recap section — a `## Summary` bullet list
  or a `## Mini Practice Task` — matching whatever the sibling chapters in that module already use.
  Two allowed variations, so a consistency sweep does not "fix" them into inconsistency: a chapter whose
  headings are **numbered** throughout keeps the number (`## 5. Summary`), and the **last chapter of a
  module** may add a module-closing epilogue *after* its recap.
- File it under the numbering scheme the profile defines (flat `NN_topic-slug.md`, or `MM-topic-slug.md`
  inside a module folder) and add it to `docs/README.md` in reading order.

### Activity (`courseware/activities/…`)
- Follow the course profile's activity format. Two common shapes:
  - **Project-folder activities:** a folder with `README.md`, `package.json`, and `begin/`/`end/`/
    `solution/` directories (students work in `end/`; `begin/` is a pristine copy; `solution/` is the
    finished result). Cumulative activities inherit the previous activity's `solution/` as their `begin/`.
  - **Instruction-file activities:** a single `activity_NN.md` of steps that students carry out against a
    shared or scaffolded project (the finished reference living in the course's demo app).
- Optional `## Stretch goal` sections are **additive and must not be reflected in any committed `solution/`**.
- Content uses the **theme(s)** named in the course profile.

### Demo (`courseware/demos/…`)
- A runnable project the instructor performs, using the **theme** named in the course profile. Depending
  on the profile this is either **one self-contained project per activity** (mirroring that activity's
  concept) or **a single reference application** the activities build toward. Include a `README.md`
  (concept + talking points + how it relates to the activities, and a *Related reading* link to the doc)
  and keep it runnable (`npm start` / `ng serve`, and any tests green).

### Exit ticket (`courseware/assessments/module-NN-exit-ticket.md`)
- **One per module** (`NN` = the module number), plus an `assessments/README.md` indexing the suite. The
  count of tickets must equal the number of modules the profile defines.
- **Formative and non-punitive:** ~5 minutes, **not graded**, anonymous is fine. Never rank or score.
- Structure: an H1 title (`# Module <N> Exit Ticket — <Module Title>`), a scope + `~5 minutes · Not
  graded` line, one friendly framing line, then **Quick Recap** (exactly 3 questions — a mix of multiple
  choice, short answer, and one "explain in your own words", all **grounded in that module's actual
  docs** — no invented content), a **Muddiest Point** prompt, a **Connect It** prompt (tie to the
  learner's prior work or the course's running project), and a **collapsed Instructor Answer Key**
  (`<details>`) that, for open-ended questions, says *what to listen for* rather than one right answer and
  closes with a short note on what the signals tell the instructor.
- Match the course voice (plain-English, encouraging). Run at the **end of each module**, not per day.

### Slide deck (`courseware/slides/md/NN-Section-Name-Slides.md`) — see *The build pipelines*
- YAML front matter (`title`, `subtitle`, `author`) → title slide.
- Authored in a plain, tool-agnostic convention that the pipeline's `preprocess.mjs` maps to Marp:
  `#` = section-divider slide (title only); `##` = content slide (bullets/code/tables beneath it are its
  body). You do **not** hand-write Marp front matter or `---` separators — the preprocessor adds them.
- **No `---` rules** — headings alone drive slide breaks. Keep bullets terse.
- **A diagram slide is a title and the image, nothing else.** Embed the PNG by relative path
  (`![Alt text](../../diagrams/png/NN-slug.png)`); the image consumes the entire body budget below, so do
  not add bullets beside it. One image per slide.
- **All content must fit on its slide.** Marp does not shrink to fit — content taller than the slide is
  clipped, silently, with no build warning. Budget the **whole body**, not each element: roughly **16
  rendered lines** total, counting every bullet, every code line, and every table row (a bullet long
  enough to wrap costs two). Split an overflowing slide into two `##` slides — the established pattern is
  a `Title (1)` / `Title (2)` pair, splitting at a natural boundary in the code.
- **Never trust the Markdown for this** — a clipped slide looks perfectly fine in the source. The rendered
  PDF is the only honest signal. Where the course has a validations harness, its slide check reads the
  generated PDFs and fails on any page that renders fewer lines than its source; regenerate the decks and
  run it after editing any deck.
- **Code/terminal blocks** are styled by the theme as bordered, smaller-monospace boxes. Use normal
  fenced code blocks with a language tag.
- **One deck per outline section.** Name files so they sort in outline order; the pipeline merges PDFs
  in filename order.

### Diagram (`courseware/diagrams/`)
- **Build it with the diagram-builder MCP tool** — not by hand-writing SVG, and not by exporting from an
  external drawing tool. The tool keeps its model inside the `.svg`, so a committed diagram can be read
  back and amended later instead of redrawn from scratch.
- **The page is fixed: US Legal landscape, 1008 × 612 pt**, origin top-left, y increasing downward. That
  is a 1.65:1 figure, wider than it is tall — design for a wide, shallow picture.
- **Three committed formats per diagram**, all sharing one `NN-slug` stem:
  - `diagrams/svg/NN-slug.svg` — the tool's own file; **this is the source, keep the embedded model**
  - `diagrams/png/NN-slug.png` — `render` at `scale: 2`; this is what content embeds
  - `diagrams/pdf/NN-slug.pdf` — `render` as vector, for printing and handouts
- **Prefer `apply_ops`** — it builds the whole diagram in one atomic call, and op N can reference an
  element created by op N-1.
- **Look at what you made.** `render` returns a PNG; check it for clipped connector labels, overflowing
  text and crossing arrows, then fix with `update_element`. A connector label needs roughly 90 pt of gap
  between the two shapes or it will be clipped — the model reports no warning for this.
- **Palette:** use the palette names (blue, indigo, teal, orange first — they stay distinguishable for
  colorblind viewers). A name sets fill, border and text together; don't hand-mix hex values.
- **Keep each one sparse.** A diagram that needs a legend is doing too much — split it. Give it a title
  label, an optional one-line subtitle, and an optional takeaway line at the bottom.
- **Register it** in the `diagrams/` index and in the course map's diagram column, and update the course
  map's counts table.

## Platform & tooling

- **Primary teaching platform is Windows.** Terminal examples default to **PowerShell**.
- **Runnable folders are small npm projects.** Static folders serve with `http-server` (`npm start`);
  script folders run with Node (`npm start`); Angular/CLI projects use `ng serve` / `ng test`.
- **Containers use podman by default** for the build pipelines (Docker supported via
  `CONTAINER_ENGINE=docker`).
- **Line endings:** every `.sh` file — whether it runs *inside* a Linux build container
  (`entrypoint.sh`, `*.mjs`, `convert.sh`, `Containerfile`) or on a macOS/Linux **host**
  (`setup.sh`, `build-all.sh`) — is forced to **LF** via a `.gitattributes` in its own folder. CRLF
  breaks the shebang. Do not let them become CRLF, and add the rule when you add a new script.
- **Paired scripts, two idioms.** Where a course ships a host script, ship both a `.ps1` and a `.sh`.
  PowerShell takes `[switch]` parameters (`-NoBuild`, `-Force`); bash takes long flags (`--no-build`,
  `--force`). Match the existing wrapper style rather than inventing a third.
- **PowerShell scripts that shell out to a native tool** and want to inspect its exit code themselves
  must set `$PSNativeCommandUseErrorActionPreference = $false`. Under
  `$ErrorActionPreference = 'Stop'`, PowerShell 7.4+ turns any non-zero native exit code into a
  terminating error — which breaks continue-on-error loops and any tool that signals "nothing to do"
  with a non-zero code.
- **A bootstrap script runs before the machine is set up.** If a course ships a `setup/` installer, its
  `.ps1` must run on **Windows PowerShell 5.1** (what a fresh image has) as well as 7+: no ternaries,
  no `??`, no `ForEach-Object -Parallel`, and **pure ASCII console output** (5.1 reads `.ps1` as ANSI
  and mangles em dashes). Installers must be **idempotent** — a second run reports "already installed"
  and succeeds — and must never continue silently past a real failure. Reserve a distinct exit code for
  "installed, but reopen your terminal"; that is not a failure and should not be reported as one.
- **Build sweeps and validation harnesses answer different questions.** A `utils/` build sweep proves
  every project **installs** (structural discovery, no manifest, no container engine). A `validations/`
  harness proves the code **runs** (manifest-driven, starts servers, hits endpoints). Keep them separate,
  and keep cleanup in exactly one of them.

## The build pipelines (md → pdf)

The course has two **containerized `md → pdf` toolchains** — one for **slides**
(`slides/utils/`) and one for the **outline** (`outline/utils/`). Both are **file-driven**, share a
`marpteam/marp-cli` base image, and are built and run the same way (podman by default; `docker` via
`CONTAINER_ENGINE`):

```bash
./convert.sh              # macOS/Linux: build image (first run) + convert
./convert.sh --no-build   # re-convert only
```
```powershell
.\convert.ps1             # Windows (PowerShell 7+)
.\convert.ps1 -NoBuild    # re-convert only
```

- **Slides:** `slides/md/*.md` → *(preprocess.mjs)* → Marp → `slides/pptx/*.pptx` + `slides/pdf/*.pdf`
  → a merged all-decks PDF (filename set by `COMBINED_NAME` in `slides/utils/entrypoint.sh`). Theme lives
  in `slides/utils/courseware.css`.
- **Outline:** `outline/md/*.md` → *(marked + puppeteer-core / headless Chrome)* → `outline/pdf/*.pdf`.
- **Generated `pptx`/`pdf` outputs are never hand-edited** — edit the Markdown source and re-run the
  pipeline. A running container engine is required (`podman machine start` the first time).

## Working rules for an agent editing this repo

1. **The outline is the source of record.** Its PDF (which the root `README.md` links to) is
   **generated** from the outline Markdown via the containerized toolchain — edit the `.md` and
   regenerate; **never hand-edit the PDF.** `docs/README.md`, the root `README.md` outline, and the
   folder `README.md` indexes are the maps. Reconcile them last.
2. **Conform to the nearest sibling.** Copy an existing file/folder of the same type and adapt; do not
   invent a new structure. *Authoring conventions per artifact* plus the course profile are the checklist.
3. **Keep the index tables in sync.** Any add/remove/renumber of a doc, activity, demo, assessment,
   slide deck, outline section, or diagram means editing every index that lists it (only those the course
   has) — **including the course map, if the course has one, and its counts table.** Divergence is a
   defect. Keep exactly one assessment ticket per module and keep the framing per-module (not per-day).
4. **Preserve the theme(s)** the course profile names (and any separation it requires).
5. **Preserve any cumulative activity chain** the profile describes.
6. **Keep content current** — verify version-specific claims with a quick web check against the course
   profile's currency baselines.
7. **Never hand-edit generated outputs** (`pptx/`, `pdf/`, `AGENTS.md`); edit the source and re-run the
   pipeline or assembler.
8. **Match voice:** plain-English, encouraging, example-driven; define jargon on first use.
9. **Renumbering docs** touches the files (and their module folders, if any) and `docs/README.md` — docs
   are not referenced by number/path elsewhere *unless the course has a course map*, which resolves docs
   down to the chapter and must be updated too. Renumbering an activity/demo means renaming its
   folder/file and updating its README index (and keeping any demo↔activity numbering the profile requires
   aligned).
10. **Adding a runnable demo or activity** means adding it to the course's validation harness, if it has
    one — usually a one-line manifest entry, not a new test file. Structural build sweeps pick it up on
    their own; manifest-driven harnesses do not.
11. **Verify before you claim.** Scripts get run (`--dry-run` / `-List` / `--verify-only` variants exist
    for exactly this), links get grepped, and counts get checked against the filesystem. "It should work"
    is not a result.

## Adapting the standards to a course

- **Course-specific values** (title, audience, day layout, themes, currency, the repo map, numbering
  scheme, how demos/activities relate, filenames) live in `AGENTS.course.md`. **Cross-course conventions**
  live here in `standards/AGENTS.base.md`.
- After editing either source, regenerate the combined `AGENTS.md` with `standards/utils/assemble` (see
  `standards/README.md`). `CLAUDE.md` imports the generated `AGENTS.md`; the Copilot instructions point at
  it; Codex, Grok, Cursor, Gemini and other tools read `AGENTS.md` natively.
- When re-deriving a sibling course, **re-build the repository map, numbering scheme, and demo/activity
  model from what is actually on disk** — courses differ structurally. Do not carry over structure that
  isn't present, and update the course profile before assuming any layout.
