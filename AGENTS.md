<!-- GENERATED FILE — do not edit. Assembled from AGENTS.course.md + standards/AGENTS.base.md
     by standards/utils/assemble.(sh|ps1). Edit those sources and re-run. -->

<!--
  [THIS COURSE] PROFILE — course-specific values for *GitHub Copilot as a Coding-Agent Harness*.

  Cross-course conventions live in standards/AGENTS.base.md. This file holds only what is
  specific to this course. The two are combined into the generated AGENTS.md by
  standards/utils/assemble.sh / standards/utils/assemble.ps1 — edit these sources, not AGENTS.md.
-->

# GitHub Copilot as a Coding-Agent Harness — Agent Guide

This guide orients an AI agent (Claude Code, GitHub Copilot, Codex, Grok, or any assistant) working on
this courseware repository. It documents **how the course is designed, how the parts relate, and the
conventions every change must preserve** — read it before editing anything. The **course profile**
below is specific to this course; the **shared standards** that follow apply to every course in the
program. Where the two disagree, this course profile wins.

This course is a **four-hour webinar**, not a multi-day class, and it departs from the base program's
default model in four deliberate ways: the demos and activities run on **sample applications** kept in
`courseware/samples/` rather than on per-activity `begin/`/`end/` scaffolds; students do every activity
in **their own copy** of one sample, pushed to GitHub; the activities **build on that one repository**;
and there is **no assessments suite**. Everything else (docs grouped into module folders, one slide deck
per outline section, a 1:1 demo↔activity pairing on two different applications, an instructor folder
with a teaching guide and a course map, generated diagrams, setup scripts, a build sweep, and a
validation harness) follows the base standards.

---

## What this repository is

- **Course:** *GitHub Copilot as a Coding-Agent Harness*
- **Duration:** one four-hour session, live over video conference, one cohort
- **Audience:** developers and technical leads working in **.NET or Java**. No prior experience with
  Copilot chat, agent mode, the Copilot CLI, or the cloud agent is assumed. They're comfortable with Git,
  pull requests, and VS Code.
- **Goal:** show that GitHub Copilot is one coding-agent harness (agent loop, tools, context files,
  approvals) that runs in VS Code, in the terminal (Copilot CLI), and on GitHub.com (the Copilot cloud
  agent), with one set of customization files shared across all three; then compare it with OpenCode
  and Kiro.
- **Delivery:** Xebia, a Microsoft Partner, delivers the course on Microsoft's behalf. Title slides
  credit **Xebia** (`author: Xebia`), and no other company is named anywhere in the course content.
  The one exception is the diagram tool's XML namespace inside `diagrams/svg/`, which the tool needs
  to read its model back and which is never rendered.
- **Environment:** an enterprise (managed user) GitHub account per participant with a Copilot seat,
  which signs in through Microsoft, in an enterprise that has Copilot Business but no GitHub Enterprise
  Cloud licenses (so no organizations: an organization would cost each member a license); and one VM
  per participant (Windows Server) with VS Code, the Copilot CLI, Git,
  the .NET SDK, and a JDK. The instructor supplies the sample projects and pre-written issues, which
  live in this repository, and publishes the orders samples as public repositories in their own
  organization for students to clone.
- **Source of record:** the outline, `courseware/outline/md/GitHubCopilotAsACodingAgentHarness_Outline.md`,
  written from the customer's webinar sheet, a `.docx` kept beside the outline in `courseware/outline/`
  on the author's machine but never committed (`.gitignore` excludes it, because the repository is
  published).
  Keep the two in step.

This is a **content repository**. Its runnable code is four small sample applications plus the
reference solutions and repro tests that overlay them. "Correctness" means pedagogical soundness,
internal consistency, factual currency about a fast-moving product, conformance to the conventions
below, and — for the code — that every sample builds and passes, every reference solution passes, and
every planted bug's repro test fails for exactly the reason its issue describes.

---

## Repository map

```
/
├── README.md                 # Public landing page: agenda, module summary, courseware links
├── LICENSE
├── AGENTS.md                 # GENERATED — AGENTS.course.md + standards/AGENTS.base.md (do not hand-edit)
├── AGENTS.course.md          # ⭐ SOURCE — this course profile
├── CLAUDE.md                 # Shim: imports @AGENTS.md
├── standards/                # Shared cross-course standards (submodule-ready; don't edit for this course)
├── .github/
│   ├── copilot-instructions.md        # Thin pointer to AGENTS.md
│   └── workflows/validate-courseware.yml
└── courseware/
    ├── samples/              # ⭐ The four sample apps everything runs on
    │   ├── README.md         # What each app is + "Make your practice repo" (students do this at the welcome)
    │   ├── library-dotnet/   # DEMO app (.NET 10, ASP.NET Core minimal API, xUnit v3)
    │   ├── library-java/     # DEMO app (Java 21, Spring Boot 4, JUnit 6, Maven Wrapper)
    │   ├── orders-dotnet/    # ACTIVITY app (.NET)
    │   └── orders-java/      # ACTIVITY app (Java)
    ├── demos/                # 4 instructor demos (scripts + assets + fallback solutions), 01..04
    ├── activities/           # 4 student activities (instructions + assets + issues + solutions), 01..04
    ├── docs/                 # 5 module folders (01..05), MM_topic-slug.md chapters; README.md is the TOC
    ├── slides/
    │   ├── md/               # ⭐ SOURCE decks: 00-Welcome … 05-Conclusion
    │   ├── pptx/, pdf/       # GENERATED (pdf/ also holds the merged all-decks PDF)
    │   └── utils/            # Containerized md → pptx → pdf → merged-pdf toolchain
    ├── outline/
    │   ├── md/               # ⭐ SOURCE outline
    │   ├── pdf/              # GENERATED
    │   ├── utils/            # Containerized md → pdf toolchain
    │   └── (webinar sheet .docx)   # the customer's webinar sheet: local only, git-ignored
    ├── diagrams/             # 10 generated figures (svg source with embedded model, png, pdf)
    ├── instructor/           # TEACHING-GUIDE.md (itinerary) + COURSE-MAP.md (join table) + README.md
    ├── setup/                # Student-machine doc, IT/org one-pager, setup.ps1 / setup.sh
    ├── utils/                # build-all.ps1 / build-all.sh — restore + build every sample, no container
    └── validations/          # Vitest harness: sample scenarios, slide clipping, links, diagrams
```

> Notes on current state:
> - **Demos and activities are numbered `01`–`04` and paired 1:1 with the four modules.** There are no
>   extension or bonus bands. The conclusion has a docs module (`05`) and a deck but no demo or activity.
> - **There is no `assessments/` folder** — see *No exit tickets* below.
> - **There are no `begin/`/`end/` scaffolds.** A sample app is the starting point, the student's own
>   repository is where the work happens, and `solution/` is the reference.

---

## The session layout

The root `README.md` and `courseware/instructor/TEACHING-GUIDE.md` carry the agenda, in relative times
so it works for any delivery date:

| Time | Block |
|---|---|
| 0:00–0:10 | Welcome; students make their practice repo |
| 0:10–1:00 | Module 1 — The Copilot harness and chat in VS Code |
| 1:00–1:50 | Module 2 — Agent mode with instructions, custom agents, and MCP |
| 1:50–2:50 | Module 3 — GitHub.com, the cloud agent and code review (break at 2:20–2:30 while the cloud agents run) |
| 2:50–3:40 | Module 4 — The GitHub Copilot CLI |
| 3:40–4:00 | Conclusion (Copilot, OpenCode, Kiro) and questions |

Each module is a **25-minute live demo**, which is the lesson, followed by a **25-minute activity**. The
slides aren't presented: they're the students' reference, and each activity links its module's deck. A
demo trail runs about 15 minutes, which leaves about ten for explaining concepts as they come up,
questions, the two-minute debrief of the previous activity, and agent latency. Module 3's activity is split around the break on purpose:
students assign their issue to the cloud agent just before it, and the pull request is ready after it.

---

## Pedagogical spine

### Progression

The session climbs the **capability ladder** across the three places Copilot runs:

- **Module 1 — VS Code chat:** model versus harness (the agent loop, tools, context assembly, approvals,
  session state), the ladder itself, chat with project context and the built-in actions, model choice.
- **Module 2 — VS Code agent mode:** tools and approvals, reading the session log, then shaping the agent
  with repository instructions, path-scoped instructions, `AGENTS.md`, custom agents, and MCP servers.
- **Module 3 — GitHub.com:** the Copilot cloud agent from an issue to a draft pull request, the checks
  inside a run, steering it, Copilot code review, PR summaries, Chat on GitHub.com, other agents.
- **Module 4 — the terminal:** the Copilot CLI interactively and programmatically, permissions and the
  sandbox, GitHub integration, the Module 2 files reused unchanged, `/review`, `/delegate`, and resuming.
- **Conclusion:** Copilot side by side with OpenCode and Kiro, where it stands out, and where it's
  constrained.

The thread through all of it: **one harness, one set of customization files, three surfaces.**

### Demos and activities (paired 1:1, two applications)

- **Two domains, two languages.** The **library** app (books, loans, due dates, late fees) is the
  instructor's demo app; the **orders** app (catalog, validation, discounts, sales tax) is the students'
  activity app. Each domain exists in .NET and in Java, with the same behavior. A demo and its activity
  teach the same concept on the two different domains, so students can't replay what they watched.
  **Don't cross them**: no orders code in a demo, no library code in an activity.
- **Demos alternate languages:** 01 and 03 in .NET, 02 and 04 in Java. Every demo still ships `dotnet/`
  and `java/` assets and solutions, so it can run in either.
- **Activities build on one repository.** The instructor publishes `orders-dotnet` and `orders-java` as
  public repositories in their own organization. Students have managed user accounts, which can't fork
  from outside their enterprise, so each student clones one sample, creates a private repository of
  the same name in their own account, swaps `origin` for it, pushes, and runs `gh repo set-default` so
  `gh` targets it; they work there for all four activities. The steps are in
  `setup/student-quick-start.md` (one page) and the samples README (with reasons). `gh auth login`
  asks for the `workflow` scope, because pushing the samples' workflow files needs it. Actions and the
  cloud agent don't run in a managed user's personal repositories, so **students never run CI, the
  cloud agent, `/delegate`, or automatic review** (managed users can't turn that on either): Activity 03
  hands its issue to agent mode on a branch, opens the pull request with `gh`, requests a Copilot review
  (the lighter one that runs without Actions), and compares with Demo 03's cloud-agent pull request,
  and Activity 04 has no `/delegate` task. Demos 03 and 04 are the room's only look at those features. Activity 02 commits the customization files (`.github/copilot-instructions.md`,
  `.github/instructions/tests.instructions.md`, `.github/agents/test-writer.agent.md`, `.mcp.json`), and
  Activities 03 and 04 rely on them being on `main`. That chain is the course's central demonstration, so preserve it.
  Activity 02's `assets/` doubles as the catch-up kit for anyone who fell behind.
- **Folder shape.** A demo folder holds `README.md` (the trail) plus `assets/{dotnet,java}/`,
  `issues/{dotnet,java}.md`, and `solution/{dotnet,java}/` as needed. An activity folder holds the same.
  `assets/` and `solution/` trees **mirror the sample's own paths**, so laying one over a copy of the
  sample is a plain copy; that's how students use them and how the harness tests them.
  `## Stretch goal` sections stay additive and are never reflected in `solution/`.
- **Output isn't deterministic.** Demo and activity steps describe what you should *see*, never exact
  output. Every demo README has an **If Copilot does something different** section, and every demo has
  a `solution/` the instructor can drop in.
- **Demo prompts are written out in full.** Every prompt the instructor types in a demo trail (chat and
  CLI prompts, follow-ups, decline reasons, pull request comments, slash commands, including the ones
  in **Before class** and **If Copilot does something different**) sits word for word in its own
  `text` block, ready to paste, and shell commands sit in `powershell` blocks. Don't leave "ask it
  to…" without the words, and name an issue by its title rather than a `#N` the instructor would
  have to fill in.

### Currency

Copilot ships weekly, and this course is about Copilot, so currency is the biggest risk to its accuracy.
**Verify every product claim against docs.github.com/copilot, github.blog/changelog, and
code.visualstudio.com/docs before you assert it**, and prefer describing behavior over quoting exact
button labels. As of the last verification (November 2026):

- **Names:** say **Copilot cloud agent** (formerly "coding agent"); the web experience is **Copilot in
  the cloud**. Copilot code review, Copilot CLI (`copilot`, GA; the old `gh copilot` extension is
  retired), the Copilot app (desktop, GA), Copilot SDK (GA, MIT-licensed, including .NET and Java;
  announced 2026-10-28 as becoming the **Microsoft Copilot SDK**, migrating in phases, repo still
  `github/copilot-sdk` as of 2026-11-09). The SDK is client libraries that drive the agent runtime the
  CLI hosts; don't say the SDK *is* the runtime.
- **Billing** is in **AI Credits** (token-metered, 1 credit = $0.01). "Premium requests" and multipliers
  are legacy terms. **Copilot Fusion** (GA 2026-10-28) can appear beside or instead of Auto in pickers.
- **VS Code** is harness-based: the **Copilot harness** is the default (since 1.143), built-in agents are
  Ask, Agent, and Plan, Edit mode is gone, and `@workspace`-style participants are deprecated (teach
  `#codebase`). Copilot Chat is built into VS Code; there's no separate extension to install.
  `/instructions`, `/agents`, `/tools`, and `/init` are **Local-harness only**; in a Copilot-harness
  session, check loaded instructions with **References** on a response.
- **Customization files:** `.github/copilot-instructions.md`; `.github/instructions/*.instructions.md`
  with `applyTo` and optional `excludeAgent: "code-review" | "cloud-agent"`; `AGENTS.md`; custom agents
  in `.github/agents/NAME.agent.md`; MCP in the portable `.mcp.json` (`mcpServers`, stdio servers use
  `"type": "stdio"`), which the VS Code Copilot harness and the CLI both read (in the CLI, since 1.0.108,
  a folder's `.mcp.json` replaces its `.github/mcp.json` rather than merging with it); `REVIEW.md` for
  code review.
- **Cloud agent:** issue-assigned sessions run on **GitHub Actions** and use
  `.github/workflows/copilot-setup-steps.yml` (job named `copilot-setup-steps`, 59-minute cap); they're
  viewable only on GitHub.com. Newer cloud-sandbox sessions ignore that file, can span repositories in
  one organization, and resume across clients. Pull requests are drafts; workflows wait until someone
  with write access, the requester included, clicks **Approve and run workflows**; the requester's own
  approval of the pull request doesn't count. The runner may not have `mvnw`'s executable bit, so Java
  instructions say `sh ./mvnw`. Copilot Memory is GA (2026-10-28).
- **Code review** comments by default; approvals are GA (2026-10-28) but off until an admin enables
  them, and Max effort is in preview. It reads instructions from the pull request's head branch.
  Automatic review comes from a ruleset (admins; private repos need Team or Enterprise) or, since
  2026-09-23, from a user's personal Copilot settings for their own pull requests, which Activity 03
  turns on.
- **Copilot CLI:** `copilot login` opens the browser (device code is the fallback). Manual mode lets
  reads through and asks for edits and other commands. The built-in GitHub MCP server is read-only by
  default, so the CLI opens pull requests with `gh pr create` (students need `gh` signed in) or
  `/pr create`. The local sandbox (`--sandbox`, `/sandbox enable`) needs Windows 11 25H2 with
  KB5124010+ or 26H1 with KB5124006+, so it can't run on the Windows Server VMs; the instructor
  demonstrates it in Demo 04, and the activity offers it only to students whose machines qualify.
  `copilot --cloud` runs an interactive session in a cloud sandbox (billed by usage). Only
  cloud-sandbox sessions come back to the terminal with **Continue in Copilot CLI**; issue-assigned
  Actions sessions stay on the website.
- **Comparison products** move too: OpenCode 2 removed its GitHub Action in v2.2.0; Kiro Web's
  autonomous mode opens pull requests. Re-check before teaching the conclusion.
- **Sample stacks:** **.NET 10** (LTS) with ASP.NET Core minimal APIs and **xUnit v3 4.x**, which runs
  on Microsoft Testing Platform, so each .NET sample's `global.json` sets
  `"test": { "runner": "Microsoft.Testing.Platform" }`. **Java 21** (`java.version` 21, runs on any
  JDK 21+) with **Spring Boot 4.1** (its starters are `spring-boot-starter-webmvc` and
  `spring-boot-starter-webmvc-test`) and the **Maven Wrapper** in only-script mode (Maven 3.10), because
  the VMs have a JDK but not Maven. No Gradle.
- **GitHub Actions** in the samples' workflows: `actions/checkout@v7`, `actions/setup-dotnet@v6`,
  `actions/setup-java@v6`.

---

## Course-specific conventions

- **Samples look like real projects.** Each sample has its own README, `CHANGELOG.md`, CI workflow, and
  `copilot-setup-steps.yml`, and **no course scaffolding**: no task comments, no hints, no mention of the
  activities, because Copilot reads all of it as context. Don't add `.github/copilot-instructions.md`,
  `.github/instructions/`, `.github/agents/`, `.mcp.json`, or `REVIEW.md` to a sample — the modules add
  those live, and the before/after comparison in Module 2 depends on their absence.
- **Planted areas, kept latent.** Each sample carries an "unfamiliar area" for Module 1
  (`DiscountPolicy`, `LateFeeCalculator` — correct but dense), an extension point for Module 2
  (`OrderValidator`, `LoanPolicy`), room for a Module 3 feature, and **one latent bug for Module 4**
  (orders: `TaxCalculator`'s rounding; library: `DueDateCalculator`'s closed-day roll-forward). The bugs
  have **no test in the sample**; their repro tests live in the module's `assets/` and are copied in at
  the start of Module 4, so agent mode in Module 2 never sees a red test to "fix". Never reveal the bugs
  in docs, slides, or sample comments, and never add a sample test that exposes them.
- **The two languages stay in step.** A behavior change to one sample goes into its other-language twin
  in the same change, along with every overlay (`assets/`, `solution/`) that touches it.
- **American English in code too:** `OrderStatus.Canceled` / `CANCELED`, "Noise-canceling".
- **Taught activities are timeboxed to 25 minutes.** Students aren't expected to finish: put the essential
  idea in the first two or three tasks, and treat later tasks and the stretch goal as depth. Task count is
  depth, not duration; don't trim activities to equal length.
- **Dependency pinning.** .NET: every version is pinned exactly in each sample's
  `Directory.Packages.props` (central package management), `RestorePackagesWithLockFile` is on, and each
  project's `packages.lock.json` is committed; `global.json` pins the SDK band with
  `rollForward: latestFeature`. Java: the Spring Boot parent pins every transitive version, plugins are
  versioned by that parent, and the Maven Wrapper pins Maven. The validation harness pins its npm
  dependencies exactly and commits `package-lock.json`. Adding or bumping a dependency is a manifest +
  lockfile change, re-verified with the harness.
- **Line endings in samples.** Each Java sample's `.gitattributes` forces `mvnw` to LF and `*.cmd` to
  CRLF, and its workflows call `sh ./mvnw` because a copy made on Windows loses the executable bit.
- **Docs:** five module folders, `01_copilot-harness-and-chat` … `05_conclusion`, each with
  `MM_topic-slug.md` chapters, indexed in reading order by `docs/README.md`. Module `05` is the
  conclusion (no demo, no activity). The chapter list resolves outline bullet by bullet in
  `instructor/COURSE-MAP.md`.
- **No exit tickets.** This course has **no `assessments/` folder**, by decision for a four-hour session
  with 25-minute blocks. This overrides the base standard's "one exit ticket per module"; don't add one.
  The debrief happens out loud at the start of the next module (see the teaching guide).
- **Instructor material** lives in `courseware/instructor/`: `TEACHING-GUIDE.md` is the itinerary,
  `COURSE-MAP.md` is the single join table (two views plus a counts table). Don't duplicate the map into
  the guide.
- **Setup.** `setup/setup-student-machines.md` is the one-pager for the team preparing the environment,
  and it covers the **accounts and Copilot settings** (managed users allowed to create personal
  repositories; Copilot seats; Copilot in the cloud, code review, CLI, and MCP policies) as well as VM
  software.
  `setup/README.md` is the student guide and `setup/student-quick-start.md` the one-page welcome steps. `setup.ps1` /
  `setup.sh` install VS Code, Git, the GitHub CLI, the Copilot CLI, PowerShell 7 (Windows; the Copilot
  CLI needs PowerShell 6+), the .NET 10 SDK, and JDK 21. Both scripts stay **idempotent**, never continue
  silently past a real failure, and keep `-VerifyOnly` / `--verify-only` and `-DryRun` / `--dry-run`.
  `setup.ps1` stays **Windows PowerShell 5.1-compatible** with **pure ASCII** output, and exit code 3
  means "installed, reopen your terminal". Verify winget, Homebrew, and apt IDs before changing them.
- **`courseware/utils/` is the build sweep.** `build-all.ps1` / `build-all.sh` discover every
  `*.slnx` and `pom.xml` under `samples/` (plus the harness's `package.json`) structurally, and restore
  and build each one. It doubles as a cache warm-up when preparing a VM image. No container engine. Keep
  `$PSNativeCommandUseErrorActionPreference = $false` in the PowerShell script.
- **`courseware/validations/` is the proof.** `lib/manifest.js` lists scenarios: a sample plus zero or
  more overlay folders, expected to pass, or expected to fail **only** on a named test. `npm test` runs
  them with the real `dotnet test` and Maven Wrapper, plus the slide-clipping check, a relative-link
  check across every Markdown file, and the diagram triplet check. Adding a demo or activity that ships
  code means adding its scenarios to the manifest. `npm run clean` owns cleanup.
- **Diagrams** — ten, numbered `01`–`10` in module order, each committed as `svg/` (the diagram-builder
  source, keep the embedded model), `png/` (scale 2, what content embeds), and `pdf/`. Embed with
  `![Alt](../../diagrams/png/NN-slug.png)`, which works from docs chapters, decks, and demo/activity
  READMEs alike. Register each in `diagrams/README.md` and the course map.
- **Slides** are one deck per outline section plus `00-Welcome`: `00`…`05`. The pipeline's footer
  (`COURSE` in `slides/utils/preprocess.mjs`) and the merged PDF's name (`COMBINED_NAME` in
  `slides/utils/entrypoint.sh`, `GitHub-Copilot-as-a-Coding-Agent-Harness-All-Slides.pdf`) carry the
  course name, and `validations/unit/slides.test.js` strips that footer — change all three together.
  The merge step picks up **every** PDF in `slides/pdf/`, so delete a deck's PDF when you delete the deck.
  The pipelines run with podman or Docker (`CONTAINER_ENGINE=docker`).
- **Editing a deck or a diagram it embeds means regenerating** (`slides/utils/convert.ps1`) and running
  `npm run test:slides` in `validations/`. The PDFs are committed.
- **The outline PDF** is `outline/pdf/GitHubCopilotAsACodingAgentHarness_Outline.pdf`, linked from the
  root README.
- **Git is a prerequisite, not a topic.** The repository's default branch is `main`.

---

<!-- ===== Shared cross-course standards (standards/AGENTS.base.md) ===== -->

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
