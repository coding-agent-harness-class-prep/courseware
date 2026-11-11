# Teaching Guide — GitHub Copilot as a Coding-Agent Harness

This is the itinerary: what happens when, how long it takes, and what to watch for. For *what goes with
what* (each outline bullet resolved to its chapter, slide deck, demo step, activity task, and diagram),
see the [course map](COURSE-MAP.md). The two files have different jobs; keep the map in the map.

---

## How the pieces fit

The session is four hours, live over video conference, for .NET and Java developers who haven't used
Copilot's agent features yet. It's organized around the three places Copilot runs (VS Code, GitHub.com,
and the terminal), with one idea running through all of it: the same harness, reading the same
customization files, sits behind every surface.

- **Slides** (`slides/pdf/`) are the students' reference, not something you present: one deck per
  module plus a welcome deck and a conclusion deck. Each activity links its module's deck, so students
  can review the concepts while they work or afterward.
- **Demos** (`demos/`) run on the **library** sample app, alternating .NET and Java.
- **Activities** (`activities/`) run on the **orders** sample app, in each student's own repository and
  their own language. They build on one repository: the customization files from Activity 02 are read
  by agent mode and code review in Activity 03 and the CLI in Activity 04. Students' enterprise
  accounts keep that repository in their personal account, where Actions and the cloud agent don't
  run, so the cloud agent, CI, and `/delegate` are yours to show in Demos 03 and 04.
- **Docs** (`docs/`) are the students' reference for afterward. You don't read them aloud.
- **Samples** (`samples/`) are the four small apps everything runs on.

### The module rhythm (25 + 25)

Each of the four modules is 50 minutes, split evenly:

1. **Teach through the live demo (25 minutes).** Follow the trail in that module's demo README, on the
   library app. The trail's steps add up to about 15 minutes; spend the other ten explaining each
   concept as it comes up (the module's **Teach** list below and each demo's **What it demonstrates**
   name them), taking questions, and waiting on the agent when it's slow. Narrate the approvals out
   loud; the audience learns the approval model by hearing you decide.
2. **Students do it (25 minutes).** Paste the activity link in the meeting chat and stay available.
   The activity uses the orders app, so it's new code to them, and it links the module's deck for
   anyone who wants to review a concept.
3. **Debrief (folded into the next module).** Open the next demo with two minutes of "what did Copilot
   do differently for you?" It's the best evidence you'll get that the output isn't deterministic, and
   it comes out of the demo's spare ten minutes.

#### Activities are timeboxed to 25 minutes

Students aren't expected to finish. The first two or three tasks of every activity carry the concept;
later tasks and the **Stretch goal** go deeper for people who move quickly. Call time at 25 minutes
whether or not the room is done, and point at the activity's `solution/` folder for later.

---

## Agenda

| Time | Block | Material |
|---|---|---|
| 0:00–0:10 | Welcome, environment check, students make their practice repo | [samples README](../samples/README.md#make-your-practice-repo-do-this-during-the-welcome) |
| 0:10–1:00 | **Module 1** — The Copilot harness and chat in VS Code | Demo 01 → Activity 01 |
| 1:00–1:50 | **Module 2** — Agent mode with instructions, custom agents, and MCP | Demo 02 → Activity 02 |
| 1:50–2:15 | **Module 3** lesson and demo — the cloud agent and code review | Demo 03 |
| 2:15–2:20 | Activity 03, part 1: create the issue and hand it to agent mode on a branch | Activity 03, Tasks 1–2 |
| 2:20–2:30 | **Break** | |
| 2:30–2:50 | Activity 03, part 2: finish, open the pull request, request code review, compare with the cloud agent's | Activity 03, Tasks 3–6 |
| 2:50–3:40 | **Module 4** — the GitHub Copilot CLI | Demo 04 → Activity 04 |
| 3:40–3:55 | **Conclusion** — Copilot, OpenCode, and Kiro side by side | Discussion (deck 05 for reference) |
| 3:55–4:00 | Questions and wrap-up | |

The break sits inside Module 3, between the two parts of Activity 03. Students start agent mode on
their issue just before it, and whatever approvals it's waiting on are there when they come back.

---

## Module by module

### Welcome (0:00–0:10)

Introduce the session and its agenda, then paste the
[student quick start](../setup/student-quick-start.md) in the chat. Students' enterprise accounts
can't fork your public samples, so each student clones one, creates a private repository in their own
account, and pushes the clone there; the quick start has the commands, and the
[samples README](../samples/README.md#make-your-practice-repo-do-this-during-the-welcome) explains them.
Have everyone make their practice repo while you take questions, and ask the room to post its URL. You'll
learn in five minutes who has an environment problem, while there's still time to fix it. Read the URLs
as they arrive: each should start with the student's own username. One that starts with
`coding-agent-harness-class` means they're looking at your original. If a student can't create a
repository at all, they can still do Modules 1 and 2 and most of Module 4 in their local clone.

Tell the room once, up front, that their accounts' personal repositories can't run GitHub Actions or
the cloud agent, so you'll show those parts in the demos and the activities use the local agents.

### Module 1 — The harness and chat in VS Code (0:10–1:00)

- **Teach:** the model versus the harness; the capability ladder (chat, agent mode, CLI, cloud agent);
  chat with context; choosing a model.
- **Demo:** [Demo 01](../demos/01_harness-and-chat/README.md), .NET.
- **Activity:** [Activity 01](../activities/01_chat-with-context/README.md).
- **Watch for:** students using chat without `#codebase` or an attached file and getting generic
  answers. Ask them to rerun the question with context and compare.

### Module 2 — Agent mode, instructions, custom agents, MCP (1:00–1:50)

- **Teach:** agent mode, tools, and approvals; reading the session log; repository and path-scoped
  instructions; custom agents; MCP servers.
- **Demo:** [Demo 02](../demos/02_agent-mode-customization/README.md), Java. Push the result; Module 4
  uses it.
- **Activity:** [Activity 02](../activities/02_agent-mode-and-instructions/README.md). While students
  work, do Demo 04's Before class step 2 on the repository you just pushed: add the failing test, push
  it, and file the bug. Not before Demo 02, which has to start green.
- **Watch for:** students who skip the commit and push at the end of **Task 3**. Activities 03 and 04
  depend on the instructions files being on `main`, and that push is the one that matters; Task 6
  pushes the rest. At 1:45, tell anyone who has reached Task 3 but hasn't pushed to do its step 6 now.
  Anyone still on Task 1 or 2 shouldn't push from there, because their repository doesn't have the
  instructions files yet: send them to the
  [catch-up commands](../samples/README.md#if-you-fall-behind), which copy in and push the same files.

### Module 3 — The cloud agent and code review (1:50–2:50, with the break)

- **Teach:** assigning issues and the Agents tab; the Actions environment and `copilot-setup-steps.yml`;
  validation inside a run; writing issues the agent can act on; custom agents, Spaces, and Memory; code
  review; pull request summaries and Chat on GitHub.com; third-party agents.
- **Demo:** [Demo 03](../demos/03_cloud-agent-code-review/README.md), .NET, on two sessions you started
  **before class**: the overdue-loans feature, and a loan-history export that pins a package with a
  published advisory, which NuGet's audit, the run's dependency check, or both will flag. Slow down on that step with this audience; it's the course's
  clearest look at the security checks.
- **Activity:** [Activity 03](../activities/03_cloud-agent-and-review/README.md), split around the
  break. Students can't assign the cloud agent in their personal repositories, so they hand the issue
  to agent mode on a branch, open the pull request themselves, and request a Copilot review; Task 6
  sends them to your Demo 03 pull request to compare. Keep `library-demo-dotnet`'s pull requests open
  for that, and walk the session log a second time if the room wants it.
- **Watch for:** agents still running at 2:40. Point those students at Task 3's reference-solution
  copy so they reach the pull request and the review. Code review in a personal repository runs
  without Actions, so it's a lighter review than the one in your demo; say so if someone compares.
  Automatic review of your own pull requests isn't available to managed user accounts, so don't send
  students to turn it on.

### Module 4 — The Copilot CLI (2:50–3:40)

- **Teach:** what the CLI is and how it differs from `gh`; installation; interactive and programmatic
  use; permissions, allow and deny rules, the local sandbox, and `copilot --cloud`; the built-in GitHub
  integration; reusing the Module 2 files; `/review`, `/delegate`, and coming back from the cloud.
- **Demo:** [Demo 04](../demos/04_copilot-cli/README.md), Java, on Demo 02's repository, with the
  local sandbox on. Windows Server VMs can't run the local sandbox, so for most students this demo is
  their look at it; say so, and make the blocked command in step 5 count.
- **Activity:** [Activity 04](../activities/04_copilot-cli/README.md).
- **Watch for:** students who approve everything with option **2** in the first minute. Ask them to
  decline one step with a reason and see how the agent responds. If Task 5 stalls at the pull request,
  check `gh auth status` first: the CLI opens it with `gh pr create`, which can't work until `gh` is
  signed in. If a student's pull request turns up in your public repository instead of their own,
  their clone still points `gh` at your original: close it, have them run
  `gh repo set-default <their-username>/<their-repo>`, and ask again. `/delegate` doesn't work in
  students' personal repositories, so the handoff in Demo 04's step 7 is the room's look at it; take
  your time there.

### Conclusion (3:40–3:55)

Talk through how Copilot compares with OpenCode and Kiro on model choice, context, approvals and
sandboxing, the path from a task to a pull request, and open source, then name where Copilot stands out
and where it's constrained. Deck 05's comparison tables are there if you want one on screen, and the
[conclusion chapters](../docs/05_conclusion/) have the detail. Keep it factual and invite the room's
experience: several people will have used one of the other two.

---

## Before the session

**A week before**

- Send the team preparing the environment the
  [student-machine and account checklist](../setup/setup-student-machines.md). The accounts matter as
  much as the VMs: a Copilot seat for every participant, and the Copilot in the cloud, Copilot code
  review, Copilot CLI, and MCP servers in Copilot policies enabled for those seats. If the accounts are
  managed users, their personal repositories can't run Actions or the cloud agent; a class organization
  in their enterprise restores both, but in a Copilot Business-only enterprise each member of an
  organization also needs a GitHub Enterprise Cloud license.
- Publish the two orders samples as **public** repositories in your organization, so students can clone
  them. Copy each one out of the courseware so the repository holds only the sample:

  ```powershell
  # from the root of your courseware clone
  New-Item -ItemType Directory -Force $HOME\publish | Out-Null
  Copy-Item -Recurse courseware\samples\orders-dotnet $HOME\publish\orders-dotnet
  Set-Location $HOME\publish\orders-dotnet
  git init -b main; git add .; git commit -m "Orders service (.NET)"
  gh repo create coding-agent-harness-class/orders-dotnet --public --source . --push
  ```

  Do the same for `orders-java`. If a sample changes later, publish it again; the validation harness
  tests the copy in `courseware/samples/`, not the published one. The courseware goes out the same
  way, as a one-commit copy of the tracked files published as `coding-agent-harness-class/courseware`,
  never by making the authoring repository public.
- Ask for one test account and do a full dry run on a student VM, following the student quick start:
  copy a sample into a private repository in the account, open a pull request on a branch, request a
  Copilot review on it, and open a pull request from the CLI. Check that the account can create a
  personal repository at all, that Copilot is offered as a reviewer, and that the CLI's pull request
  lands in the student's repository rather than in yours.

**The day before**

- Rehearse all four demos end to end on the build of VS Code and the CLI you'll be using. Both ship
  weekly, so UI labels drift; correct your patter, not the students' expectations. Confirm that your
  own machine runs the CLI's local sandbox (Demo 04, Before class step 4).
- Clone the three demo repositories into `$HOME\demo` (the
  [demos README](../demos/README.md#running-a-demo) has the commands), after you've rehearsed. A
  rehearsal that pushes or creates something on GitHub leaves the repository in its end state, so
  recreate any repository you rehearsed on first; the same README says how, including Demo 03's three
  issues and its backup pull request.

**The morning of**

- Update VS Code and the CLI on your machine to match the VMs.
- Start both of Demo 03's cloud-agent sessions **at least 30 minutes** before Module 3, and read the
  loan-export log once they finish, so you know where its advisory surfaced (Demo 03, trail step 4).
- Start and finish Demo 04's cloud-sandbox session for the return trip (its Before class step 5),
  before class and before any failing test is on that repository's `main`.
- Open, in browser tabs: your two public sample repositories, both demo repositories,
  `github.com/copilot`, and the courseware repository's `activities/` folder (for pasting links).

---

## Facilitation notes

- **Expect different output on every screen.** Two students running the same prompt will get different
  code, and that's part of the lesson: the skills being taught are reading what the agent did, deciding
  whether it's right, and steering it. The activities describe what students should *see*, never exact
  output.
- **Over video, narrate your decisions.** When an approval prompt appears in a demo, read it aloud and
  say why you're approving or declining. Zoom the editor and terminal; paste every link into the chat.
- **Help stuck students in the open.** If someone's environment fails, have them watch your screen for
  that activity and catch up from the `solution/` folder; don't debug a VM for ten minutes while the
  room waits.
- **When a cloud run fails,** the session log or the pull request usually says why: a request the
  firewall blocked (Copilot adds a warning to the pull request), a failed setup step, or missing write
  access. Show one failed log to the room if you get the chance; it demystifies the agent.
- **When students ask about cost,** explain that chat and agent usage is billed in AI Credits, drawn
  from a monthly pool the organization's seats fill, and that cloud agent runs and code reviews also
  use GitHub Actions compute. It's a good moment to say why model choice matters.
- **Running late?** Trim from the end of activities first (the later tasks are depth), then shorten the
  conclusion to ten minutes. Never skip Activity 02's push.
