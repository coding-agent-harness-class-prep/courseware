# What the Copilot CLI Is

Everything you did with agent mode in Module 2 had three moving parts: a model, the harness wrapped
around it, and your repository. The GitHub Copilot CLI keeps all three and trades the editor for a
terminal. You start it with one command inside a repository folder, describe a task in plain English,
and the agent reads files, runs your build, edits code, and asks before it does anything you haven't
allowed. If you already spend your day in PowerShell running `dotnet test` or `.\mvnw.cmd test`, it's
the most direct way to put Copilot to work on a real codebase.

---

## The same harness, in a terminal

Module 1 defined the **harness** as the software around the model: the agent loop that turns your
request into a sequence of tool calls, the tools themselves (reading and editing files, running shell
commands, searching, talking to GitHub), the code that assembles context for each request, the
approval gate, and the session state that remembers what's happened so far. The model decides what to
do next, and the harness is what actually does it.

Under the hood, the CLI hosts Copilot's agent runtime, and the **Copilot SDK** is how other programs
drive that same runtime: GitHub describes the SDK as exposing "the same engine behind Copilot CLI".
VS Code's default Copilot harness is built on the SDK, and GitHub's cloud sessions get the same tools
the CLI has, which is why a session can move between VS Code, the Copilot app, the CLI, GitHub.com,
and GitHub Mobile.

Three practical consequences follow from that, and the rest of this module leans on each of them:

- The instruction files, custom agents, and MCP configuration you committed in Module 2 load in the
  terminal without changes (chapter 5).
- Approvals work the same way, even though they look different: a numbered prompt in the terminal
  instead of a button in the chat view (chapter 3).
- Work can start in one place and finish in another, so a terminal session can be handed to the cloud
  agent and picked up again later (chapter 5).

### What's different about the terminal

You lose the editor's inline diff view and gain things the editor doesn't have. `/diff` shows what
changed, a `-p` flag runs a single prompt from a script or CI job and exits (chapter 2), `/sandbox`
puts the agent's shell commands inside an operating-system sandbox (chapter 3), and `/delegate` sends
the session to the cloud agent (chapter 5). The CLI also runs as *you*, on your machine, with your
toolchain and your credentials, which is why the permission model gets a whole chapter.

If you're curious about the runtime underneath, the Copilot SDK became generally available on
2026-06-02 with **.NET** and **Java** among its languages (alongside Node/TypeScript, Python, Go, and
Rust). GitHub announced on 2026-10-28 that it's becoming the **Microsoft Copilot SDK**, moving to
Microsoft's GitHub organization in phases with the package names unchanged for now. This course
doesn't build on the SDK, but it's the same runtime you're driving from the CLI.

---

## `copilot` versus `gh`

There are two command-line tools with GitHub's name on them, and they do different jobs. `gh` is the
**GitHub CLI**: a precise, scriptable client for repositories, issues, pull requests, and Actions.
`copilot` is the **GitHub Copilot CLI**: a coding agent you talk to. There used to be a third,
`gh copilot` (with `suggest` and `explain` subcommands), but that extension was deprecated in
September 2025 and stopped working on 2025-10-25. If an old blog post tells you to run
`gh copilot suggest`, it's describing a tool that no longer exists.

| Command | What it is | Reach for it when |
|---|---|---|
| `copilot` | The Copilot CLI, an interactive coding agent | You want an agent to read, change, build, and test code |
| `gh` | The GitHub CLI | You want to perform a GitHub operation yourself, exactly |
| `gh copilot` | The retired Copilot extension for `gh` | Never; it was retired in October 2025 |

`gh` still matters for two Copilot jobs. It can start and follow cloud-agent tasks with
`gh agent-task` (gh v2.80.0 or later; the command set is still a public preview), and it can ask
Copilot code review to look at a pull request:

```powershell
gh agent-task create "Add unit tests for the senior fee-free days in LateFeeCalculator"
gh agent-task list
gh pr edit 42 --add-reviewer '@copilot'    # quoted: a bare @ is splatting in PowerShell
```

The agent can also run `gh` itself as one of its shell commands when it's installed, which is why
permission rules can name it. `shell(gh pr)` covers `gh pr create` and every other `gh pr` command,
because `gh` rules match on the first subcommand only; chapter 3 explains how these rules work.

---

## Installing the CLI

You need an active Copilot subscription, and on Windows you need **PowerShell 6 or later**. The
Windows PowerShell 5.1 that ships with Windows isn't enough, so install PowerShell 7 first if
`pwsh` isn't on your machine. On Business and Enterprise plans an administrator has to enable the
Copilot CLI on the Copilot **Policies** page before anyone in the organization can use it.

| Method | Command | Notes |
|---|---|---|
| WinGet | `winget install GitHub.Copilot` | Prerelease builds: `GitHub.Copilot.Prerelease` |
| Homebrew | `brew install --cask copilot-cli` | It's a cask; prerelease: `copilot-cli@prerelease` |
| npm | `npm install -g @github/copilot` | Needs Node.js 22 or later |
| Install script | `curl -fsSL https://gh.io/copilot-install \| bash` | macOS and Linux; `wget -qO-` also works |
| Standalone | Binaries on the `github/copilot-cli` releases page | For locked-down machines |

On Windows:

```powershell
winget install Microsoft.PowerShell        # skip if pwsh is already installed
winget install GitHub.Copilot
copilot --version                          # prints the installed version
```

On macOS or Linux:

```bash
brew install --cask copilot-cli            # macOS with Homebrew
curl -fsSL https://gh.io/copilot-install | bash   # or the script, on macOS or Linux
```

The install script downloads the release archive for your platform from GitHub, checks it against the
published `SHA256SUMS.txt`, and puts the binary at `$PREFIX/bin/copilot`. `PREFIX` defaults to
`/usr/local` when you run it as root and to `$HOME/.local` otherwise, and `VERSION` takes `latest`
(the default), `prerelease`, or a tag. Pinning a tag is handy when a whole classroom or build agent
pool should run the same build:

```bash
curl -fsSL https://gh.io/copilot-install | VERSION=vX.Y.Z bash   # a tag from the releases page
```

If you run the script from a Windows shell such as Git Bash, it calls `winget install GitHub.Copilot`
for you. One caution for prerelease users on Windows: when this was written the WinGet prerelease
package lagged well behind the npm and Homebrew prereleases, so compare version numbers before you
assume you're on the newest preview.

### Staying current

The CLI updates itself by default, except in CI, where auto-update is off (an npm install only tells
you a newer version exists, and updating it stays a manual `npm install`). You can also run
`copilot update` (or `/update` inside a session), and you can turn automatic updates off with
`--no-auto-update` or `COPILOT_AUTO_UPDATE=false`. New releases come out several times a week, so
`/changelog` is worth a look when a command behaves differently from last week.

---

## Signing in

On a desktop, signing in opens your browser, you approve the CLI there, and the terminal picks up the
result on its own. Over SSH, in a dev container, or on another headless machine it switches to a
device code that you type into a browser somewhere else.

```powershell
copilot login          # or /login inside a session; /logout and /user manage accounts
copilot login --device-code   # force the device-code flow
```

For automation, the CLI reads a token from the environment instead. It checks
`COPILOT_GITHUB_TOKEN`, then `GH_TOKEN`, then `GITHUB_TOKEN`, and whichever it finds first takes
precedence over the account you signed in with. Use a fine-grained personal access token with the
**Copilot Requests** permission (classic `ghp_` tokens aren't supported). For GitHub Enterprise Cloud
with data residency, `GH_HOST` (or `COPILOT_GH_HOST`, which only the Copilot CLI reads) points it at
your host.

That precedence order has a side effect worth knowing. If you exported `GH_TOKEN` months ago for some
`gh` script, the Copilot CLI will use it ahead of your `/login` account, and the session may run as a
different identity or fail on a token without the right permission. A quick check:

```powershell
Get-ChildItem Env: | Where-Object Name -in 'COPILOT_GITHUB_TOKEN', 'GH_TOKEN', 'GITHUB_TOKEN'
```

---

## Trusted folders

The first time you launch `copilot` in a folder, it asks you to confirm that you trust the files in,
and below, the directory you launched it from. The wording of the prompt varies between builds, but
the decision is the same. Trust is what lets the CLI load the folder's own configuration: a project
`.mcp.json` loads only in a trusted folder, and trusting a folder also loads its skills, plugins, and
hooks, including hooks that run shell commands.

Two habits follow from that. Launch the CLI from the repository root you actually mean to work in, not
from your home directory or the root of a drive, and treat trusting a freshly cloned repository the way
you'd treat running its build script, because in effect you're letting it configure your agent. For a
one-off scripted run, `--trust-folder` trusts the folder for that single prompt-mode session without
saving the decision.

---

## Where it sits on the ladder

The Copilot CLI has been generally available since 2026-02-25, after a public preview that began in
September 2025. On the capability ladder from Module 1 (chat, agent mode, the CLI, the cloud agent) it
sits one rung above agent mode. The loop is the same, but nothing about it depends on an editor, so it
runs just as well inside a script or a CI job, and it can hand work up to the cloud agent or take it
back. The CLI's license is proprietary: the public `github/copilot-cli` repository holds the README,
changelog, and install script, not the source. The Copilot SDK, by contrast, is open source under the
MIT license.

To try it on this course's demo app, open [the library sample](../../samples/library-java/README.md)
in a terminal and run `copilot` from its root.

---

## Summary

- The Copilot CLI (`copilot`) is the Copilot harness in a terminal. The Copilot SDK exposes the same
  runtime to your own programs, VS Code's Copilot harness is built on the SDK, and cloud sessions
  share the CLI's tools.
- `gh` is the GitHub CLI and still has Copilot jobs (`gh agent-task`, `--add-reviewer '@copilot'`);
  the old `gh copilot` extension stopped working on 2025-10-25.
- Install with WinGet (`GitHub.Copilot`), Homebrew (`--cask copilot-cli`), npm (`@github/copilot`,
  Node 22+), or the install script; Windows needs PowerShell 6 or later.
- Sign in with `copilot login` (a browser flow on a desktop), or supply `COPILOT_GITHUB_TOKEN` /
  `GH_TOKEN` / `GITHUB_TOKEN` (in that order) with a fine-grained token that has the Copilot Requests
  permission.
- Trusting a folder lets its MCP servers, skills, plugins, and hooks load, so launch from the repo
  root and trust only what you'd be willing to build.
