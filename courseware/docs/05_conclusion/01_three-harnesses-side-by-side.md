# Three Harnesses Side by Side

Copilot isn't the only harness that will drive a frontier model through your codebase. OpenCode and
Kiro run the same basic loop you've used all session, where a model proposes a tool call, the harness
checks whether it's allowed, runs it, and feeds the result back. Where they differ is in who chooses
the model, where it runs, which files shape its behavior, how it's contained, how work becomes a pull
request, and how much of it you can read the source for. This chapter compares them on exactly those
points, using what each vendor documented as of November 2026.

---

## The three, briefly

### GitHub Copilot

You've spent four modules here, so a recap is enough. Copilot's harness runs in VS Code (where the
Copilot harness is now the default), in the Copilot CLI, in the desktop Copilot app (generally
available since June 2026), and on GitHub.com and GitHub Mobile as **Copilot in the cloud**, the
unified web experience that launched for paid plans on 2026-10-28. The Agents panel on GitHub can also
run third-party agents from Anthropic and OpenAI, which are still in public preview.

### OpenCode

OpenCode bills itself as the open-source coding agent. It's developed by Anomaly in the
`anomalyco/opencode` repository (the older `sst/opencode` address redirects there) under the MIT
license. There are two lines: **OpenCode 2** (npm `@opencode/cli`) is current, and **OpenCode 1** (npm
`opencode-ai`) is still maintained. Both use the `opencode` command and can't be installed side by
side, and their configuration differs in ways that matter if you copy examples from the web. The
surfaces are a terminal UI, a desktop app for macOS, Windows, and Linux, and a web view you reach
through `opencode pair`, which prints a one-time link that expires in five minutes. Its built-in
primary agents are `build` (the default) and `plan`, plus `general` and `explore` subagents.

On Windows, OpenCode 2 doesn't support package managers, so you use the standalone binary or npm.
OpenCode 1 can be installed with Chocolatey, Scoop, or Docker, and its docs recommend WSL.

### Kiro

Kiro comes from AWS, and its README says one unified agent harness powers every Kiro surface. Those
surfaces are an IDE based on Code OSS (it imports VS Code settings and uses Open VSX-compatible
extensions; WinGet ID `Amazon.Kiro`), a CLI called `kiro-cli` (version 3.0 and later default to the
"V3" harness), Kiro Web at `app.kiro.dev` (generally available since September 2026), an iOS app in
TestFlight early access, and Kiro Crew. Kiro also has **specs**, a structured planning workflow: a
feature spec produces `requirements.md` (written in EARS notation,
`WHEN [condition] THE SYSTEM SHALL [behavior]`), `design.md`, and `tasks.md`, and tasks run in
sequential "waves" whose members run concurrently. On Windows the CLI installs with a PowerShell
one-liner, `irm 'https://cli.kiro.dev/install.ps1' | iex`.

---

## Model choice and where the model runs

**Copilot** gives you a model picker curated by GitHub. Today it spans six vendors (OpenAI, Anthropic,
Google, Microsoft, Moonshot, and xAI) plus **Auto**, which picks a model per task and gives paid plans a
10% discount on model costs in Copilot Chat and the cloud agent. Where a model runs depends on its
vendor, and GitHub publishes the hosting for each:

| Vendor | Hosted on |
|---|---|
| OpenAI | OpenAI and GitHub's Azure infrastructure |
| Anthropic | Amazon Web Services, Anthropic, and Google Cloud |
| Google | Google Cloud |
| xAI | xAI |
| Microsoft MAI | Azure, in GitHub's tenant |
| Moonshot (Kimi K3) | Fireworks AI, hosted by GitHub |

GitHub has zero-data-retention terms covering OpenAI, Anthropic, xAI, and Kimi traffic (Anthropic's
Fable models aren't covered by default), and it doesn't describe Google or Microsoft MAI traffic as
zero-retention. Usage is billed in AI Credits, metered by tokens at each model's API rate, and there's
no automatic fallback to a cheaper model when a plan's credits run out. Bring-your-own-key (BYOK) works
in VS Code, the CLI, and the Copilot app. In VS Code, **Chat: Manage Language Models** adds providers
such as Azure, Anthropic, Gemini, OpenAI, a custom endpoint, or Ollama through its extension, though
BYOK covers chat and utility tasks only and Business and Enterprise plans need the "Bring Your Own
Language Model Key in VS Code" policy. The CLI takes `COPILOT_PROVIDER_BASE_URL`,
`COPILOT_PROVIDER_TYPE`, and `COPILOT_PROVIDER_API_KEY`.

**OpenCode** is provider-agnostic. Its model catalog comes from `models.dev`, you can add or override
providers in config, and model IDs take the form `provider/model`. OpenCode 2 auto-detects local
servers for Ollama, LM Studio, and vLLM at their usual local addresses, so the model can run on your
own machine. It can also sign in with a **GitHub Copilot** subscription, a ChatGPT Plus or Pro plan, or
Amazon Bedrock through the AWS credential chain. Anomaly sells hosted models too, as pay-per-token
OpenCode Models and a low-cost OpenCode Go subscription, but nothing requires them.

**Kiro** offers its own curated list, priced in credits with a multiplier relative to Auto (1.0x):
OpenAI GPT-5.6 variants, a range of Anthropic Claude models, and open-weight models such as Kimi K3,
DeepSeek 3.2, MiniMax, GLM-5, and Qwen3 Coder Next. Models run on AWS endpoints in the US
(`us-east-1`, `us-west-2`, `us-east-2`) and the EU (Frankfurt, Ireland, Paris, Stockholm, Milan, and
Spain), and Free and individual users use the US endpoint. The docs reference Amazon Bedrock inference
profiles, though they don't say every model is Bedrock-hosted. BYOK isn't documented, so treat it as
unsupported. Plans run from Free (50 credits a month) through Pro ($20, 1,000 credits) up to Power
($200, 10,000 credits), with extra credits at $0.04 each.

---

## Context: instruction files and MCP servers

All three read project files to learn your conventions, and all three speak MCP, but the file names
and formats differ.

**Copilot** reads `.github/copilot-instructions.md` (repository-wide),
`.github/instructions/*.instructions.md` (path-scoped with `applyTo`), and `AGENTS.md` (the nearest one
in the tree wins), or a single root `CLAUDE.md` or `GEMINI.md`. Not every surface reads every file:
Copilot Chat on GitHub.com reads only the repository-wide file (plus personal and organization
instructions), and code review also reads `REVIEW.md`. Custom agents live in
`.github/agents/NAME.agent.md`. MCP servers go in a workspace `.mcp.json` or
`~/.copilot/mcp-config.json` under an `mcpServers` key, which the CLI and the VS Code Copilot harness
both read, while the cloud agent's MCP configuration lives in the repository's settings on GitHub.

**OpenCode 2** reads `AGENTS.md` and nothing else, with no `CLAUDE.md` fallback (OpenCode 1 has
one). That means a global `~/.config/opencode/AGENTS.md` and project `AGENTS.md` files, with nested
ones loaded lazily, and an `instructions` key in `opencode.json` can pull in more files, globs, or URLs such as
`CONTRIBUTING.md`. Custom agents are Markdown files in `.opencode/agents/`. MCP servers sit under
`mcp.servers` in `opencode.json`, with `type` set to `local` or `remote`, `command` written as an
array, and `{env:NAME}` substitution.

**Kiro** calls its instruction files **steering**: Markdown in `.kiro/steering/` (defaults are
`product.md`, `tech.md`, and `structure.md`) with an `inclusion` setting of `always`, `fileMatch`,
`manual`, or `auto`. It reads `AGENTS.md` as well, which ignores inclusion modes and is always
included. Custom agents live in `.kiro/agents/` as JSON or Markdown and load only in a trusted
workspace. MCP servers go in `.kiro/settings/mcp.json` (workspace) or
`~/.kiro/settings/mcp.json` (user) under `mcpServers`, with `command`, `args`, and `env` for local
servers or `url` and `headers` for remote ones.

The practical upshot for a team that might use more than one harness is that **`AGENTS.md` is the one
instruction file all three read**. The Copilot and Kiro MCP files share the `mcpServers` shape closely
enough that porting a server is mostly copy and paste, while OpenCode's needs a rewrite.

---

## Approvals and sandboxing

**Copilot**'s controls differ by surface, so there are several sets to know. Locally, the CLI prompts
per tool call, takes allow and deny rules in which deny always wins, and offers `manual`, `assisted`,
and `allow-all` modes; VS Code has the matching Manual, Assisted, and Allow all permission levels. Both
have a local sandbox that's off by default: the CLI's covers shell commands on macOS, Linux, and recent
Windows 11 builds, and VS Code's terminal sandbox (`chat.agent.sandbox.enabled`) is still experimental
on Windows. In the cloud, the agent can be triggered only by users with write access, pushes only to its
own branch, and works behind a firewall; workflows on its pull requests don't run until someone with
write access approves them, and the person who asked for a pull request can't approve it.

**OpenCode** has rule-based permissions. OpenCode 2 writes them as an array of
`{ "action", "resource", "effect" }` entries with effects `allow`, `ask`, and `deny` (it renamed
OpenCode 1's `bash` to `shell`). A request with no matching rule asks, but the base policy allows
everything except reading `.env` files. There is **no sandbox**: the docs say "`shell` runs with the
host user's filesystem, process, and network authority", and worktrees only bound which directories
count as external.

**Kiro** has two layers of its own. The agent runs in Autopilot (the default) or Supervised mode, and
Kiro is candid that "Supervised mode is a code review workflow, not a security control". Separately,
Kiro asks before running any command you haven't trusted, and in the IDE, writes to `.vscode/`,
`.git/`, and `mcp.json` need explicit approval. Permission rules in `permissions.yaml` resolve deny,
then ask, then allow, and the workspace file is stored in your home directory rather than the
repository, so a cloned repo can't inject its own rules. Kiro also has an OS-level local sandbox for
shell commands, off by default, using Seatbelt on macOS, `bwrap` on Linux, and a Windows backend that
needs a one-time admin setup before it can open the network. Once it's on, outbound network access is
blocked by default (`DEFAULT_BLOCKED`).

---

## From a task to a pull request

**Copilot** turns a GitHub issue into a pull request without anyone opening an editor. You assign the
issue to Copilot (or start a task from the Agents tab, Copilot Chat's `/task`, the CLI's `/delegate`,
or `gh agent-task create`), and the cloud agent works in GitHub Actions or a cloud sandbox and opens
a **draft pull request**. Before it asks for review, it runs CodeQL, secret scanning, a check of new
dependencies against the GitHub Advisory Database, and a Copilot code review, with no Advanced
Security license required. You iterate by mentioning `@copilot` in pull request comments.

**OpenCode** used to offer a GitHub Action, triggered by `/opencode` or `/oc` in a comment, that could
implement an issue on a new branch and open a pull request, running on your repository's GitHub
Actions runners. **OpenCode 2.2.0 (October 27, 2026) removed that Action**, and the release notes tell
you to take it out of your workflows. Workflows pinned to the old tags keep working, but there's no
documented replacement, so in OpenCode 2 the path to a pull request is local, with the agent running
`git` and `gh` through its `shell` tool.

**Kiro** reaches pull requests through **Kiro Web's autonomous mode** (formerly the "Kiro autonomous
agent"). With the toggle on (it's off by default), the agent plans, defines acceptance criteria, runs
subagents in an isolated sandbox with a clone of the repository, picks its own model, and usually
opens one or more pull requests or merge requests. On GitHub you install the **Kiro Agent** app and
trigger it with the `kiro` label on an issue or a comment starting with `/kiro`; `/kiro all` and
`/kiro fix` handle review feedback, and it can't push to protected branches. GitLab repositories work
too. From the terminal, `kiro-cli --cloud` starts cloud sessions (up to ten at once), though
Supervised mode isn't available in them yet.

---

## What's open source

| Harness | Open source | Not open source |
|---|---|---|
| Copilot | VS Code (`microsoft/vscode`, MIT), including the Copilot Chat code built into it since 1.116; the Copilot SDK client libraries (`github/copilot-sdk`, MIT); `github/github-mcp-server` (MIT) | The Copilot CLI, which by default hosts the runtime the SDK drives (proprietary license; the repo has no source), the Copilot app (no license), the cloud agent, and the models |
| OpenCode | The whole agent repository under MIT: terminal UI, desktop app, server, and SDKs | The paid hosted services: the OpenCode Console, Go, and Models |
| Kiro | Kiro Crew and KiroCrewApps (Apache-2.0) and `spirit-of-kiro` (MIT-0) | The IDE, the CLI, and Kiro Web; `kirodotdev/Kiro` is an issue tracker with no license |

Data handling differs as well. OpenCode sends your prompts wherever you point it, including a model on
your own machine. Copilot's model traffic goes to the hosts in the table above. Copilot and Kiro have
similar rules about training: GitHub may use interaction data from Copilot Free, Pro, Pro+, and Max
users to train models unless they opt out, but not data from Business or Enterprise. Kiro may use
content from Free users and from paid users who sign in with a social login or AWS Builder ID unless
they opt out, but not from users who sign in through an identity provider.

---

## The comparison in one table

| | GitHub Copilot | OpenCode | Kiro |
|---|---|---|---|
| Surfaces | VS Code, CLI, Copilot app, GitHub.com, Mobile | Terminal UI, desktop app, web pairing | IDE, CLI, Web, iOS (early access), Crew |
| Model choice | GitHub's multi-vendor list plus Auto; BYOK in VS Code, the CLI, and the app | Any provider in the `models.dev` catalog, local models, or a Copilot sign-in | Kiro's list, priced by credit multiplier; BYOK not documented |
| Where models run | Each vendor's or GitHub's hosting (Azure, AWS, Google Cloud, and others) | Wherever your chosen provider runs, including your own machine | AWS endpoints in US and EU regions |
| Instruction files | `copilot-instructions.md`, `*.instructions.md`, `AGENTS.md`, `CLAUDE.md`/`GEMINI.md` | `AGENTS.md` only (v2) | `.kiro/steering/*.md`; `AGENTS.md` always included |
| MCP configuration | `.mcp.json` or `~/.copilot/mcp-config.json` (`mcpServers`); repo settings for the cloud agent | `mcp.servers` in `opencode.json` (v2) | `.kiro/settings/mcp.json` (`mcpServers`) |
| Approvals | Per-call prompts, allow and deny rules, manual / assisted / allow-all | `allow` / `ask` / `deny` rules; base policy allows all but `.env` reads | Autopilot or Supervised; deny > ask > allow rules |
| Local sandbox | CLI and VS Code, both off by default | None | Yes, off by default; network blocked by default once on |
| Task to pull request | Assign an issue; the cloud agent opens a draft PR after built-in checks | Local `git` and `gh` through the shell; GitHub Action removed in v2.2.0 | Kiro Web autonomous mode via the `kiro` label or `/kiro` |
| Open source | VS Code with its built-in chat, the Copilot SDK, and `github-mcp-server` (MIT) | The agent (MIT) | Kiro Crew and two small repos only |

---

## Summary

- All three harnesses run the same kind of loop; they differ in model choice, hosting, configuration
  files, containment, the path to a pull request, and licensing.
- Copilot curates a multi-vendor model list hosted by vendors and GitHub; OpenCode lets you bring any
  provider, including local models; Kiro curates its own list on AWS and doesn't document BYOK.
- `AGENTS.md` is the instruction file every one of them reads; Copilot and Kiro share an
  `mcpServers` shape, and OpenCode 2 uses `mcp.servers`.
- Copilot and Kiro both ship local sandboxes that are off by default; OpenCode has none.
- Copilot and Kiro Web both turn a GitHub issue into a pull request in the cloud; OpenCode removed its
  GitHub Action in v2.2.0 and now opens pull requests locally.
- OpenCode is MIT end to end; Copilot's main open pieces are VS Code, the SDK client libraries, and
  the GitHub MCP server; Kiro's products are proprietary apart from Kiro Crew.
