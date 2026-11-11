# Inside a Cloud Run

Between the moment you assign an issue and the moment Copilot asks for your review, the agent runs the same
loop you watched in VS Code in Module 2: read, plan, edit, run, check, repeat. The difference is that nobody
approves each step, so two other things carry the weight of keeping the work honest. One is the validation
GitHub runs on the agent's changes before it finishes, and the other is the session log, which is how you
find out afterward what the agent actually did.

---

## What the agent has to work with

A cloud session gets the same core tools as the Copilot CLI and the Copilot app, including Bash, the GitHub
CLI, and code search, so it can build and test the way you would in a terminal. On top of that it reads the
customizations in the repository:

| Customization | What the cloud agent uses |
|---|---|
| Instructions | `.github/copilot-instructions.md`, path-specific `.github/instructions/*.instructions.md` files (except those marked `excludeAgent: "cloud-agent"`), agent files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`), and organization instructions |
| Custom agents | The `.github/agents/NAME.agent.md` you picked when you started the task |
| Skills | Folders holding a `SKILL.md`, under `.github/skills`, `.claude/skills`, or `.agents/skills` |
| MCP servers | The GitHub and Playwright MCP servers, on by default, plus any you add under **Settings → Copilot → MCP servers** |
| Hooks | `.github/hooks/*.json`, for the subset of hook events the cloud agent supports |

The default GitHub MCP server runs with a specially scoped token that has read-only access to the current
repository. If a server you add needs a secret, store it in the repository's **Agents** secrets with a
`COPILOT_MCP_` prefix.

Connectors, the managed MCP integrations for services like Sentry or Linear, work in cloud sandboxes but
aren't supported yet in Actions sessions, and that includes every session started by assigning an issue.

---

## Built-in validation

While the agent works, GitHub runs a set of checks on the changes it makes. There are four of them:

| Check | What it looks for |
|---|---|
| CodeQL | Security problems in the code the agent wrote |
| Secret scanning | Credentials and tokens that ended up in the changes |
| Dependency check | New dependencies with advisories in the GitHub Advisory Database, including malware advisories |
| Copilot code review | A second opinion on the changes from Copilot's own reviewer |

None of this needs a GitHub Advanced Security, Secret Protection, or Code Security license. A team without
those licenses still gets CodeQL and secret scanning on the agent's work, which helps most if it hasn't set
up scanning of its own yet.

Repository admins choose which checks run under **Validation tools** in Settings → Copilot → Cloud agent,
and they're all on by default. The security checks also run on the work of third-party agents such as
Claude and Codex (chapter 5).

Validation narrows what reaches you, but it doesn't replace anything you already do. Your CI still waits for
**Approve and run workflows**, your tests still have to pass, and a person still has to read the diff. The
code review that runs during validation is also separate from the one you can request on the finished pull
request, which chapter 4 covers.

---

## Reading the session log

Every session keeps a log, and it streams live while the agent works. To open it from the pull request,
find the "Copilot started work" event on the timeline and select **View session**; the Agents tab links to
the same log. If you can see a run heading the wrong way, **Stop session** in the log viewer ends it and
keeps whatever it has already pushed.

The layout of the log changes from build to build, so read it for content rather than for a particular
screen. These are the questions worth answering on a first pass through a library-app session:

1. **How did it restate the task?** Compare its reading of the issue with your acceptance criteria. A
   wrong pull request often starts with a wrong reading.
2. **What did it read before it edited?** For an overdue-loans feature you'd hope to see it open
   `LoanService` and `LateFeeCalculator` rather than write a second copy of the fee rules.
3. **What did it run, and what came back?** Look for the build and test commands (`dotnet test`, or
   `sh ./mvnw -B verify` on the Java side) and check that the last run passed.
4. **What couldn't it do?** Look for a failed setup step, missing tools, failed downloads, and blocked
   network calls. Firewall blocks are also flagged as a warning in the pull request body or a comment.
5. **What did validation report?** If a check found something, see whether the agent dealt with it or left
   it for you.

GitHub keeps the chat data for an Actions session for 28 days, so if a session is worth keeping as an
example for your team, save what you need from it before then.

---

## When a run goes sideways

Most problems with a cloud run come from a short list of causes, and the session log usually tells you which
one you've hit.

| What you see | Likely cause | What to do |
|---|---|---|
| The agent installs tools or downloads packages before it can build | No setup steps, or a setup step failed and the rest were skipped | Run `copilot-setup-steps.yml` from the Actions tab and fix it on the default branch |
| A firewall warning on the pull request | A host that isn't on the allowlist | Add a custom allowlist rule, or move the download into setup steps |
| The session stops before the work is finished | The 59-minute limit on Actions sessions | Split the issue into smaller pieces |
| Copilot can't push its branch | A ruleset or branch protection rule | Grant Copilot a bypass on that rule |
| A follow-up request had no effect | It was posted as an issue comment after assignment | Mention `@copilot` on the pull request instead (chapter 3) |

---

## Summary

- A cloud session has the CLI's core tools (Bash, the GitHub CLI, code search) plus the repository's
  instructions, custom agents, skills, MCP servers, and a subset of hooks.
- Issue-assigned sessions run on Actions, where connectors aren't supported yet.
- Built-in validation runs **CodeQL**, **secret scanning**, a **dependency check** against the GitHub
  Advisory Database, and a **Copilot code review** second opinion, with no GHAS license needed. Admins pick
  the tools under **Validation tools**.
- Validation doesn't replace CI, tests, or human review.
- Open the log with **View session** on the "Copilot started work" timeline event. Read it for how the
  agent understood the task, what it read, what it ran, and what got in its way.
- Actions session chat data is kept for 28 days.
