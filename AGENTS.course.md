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
