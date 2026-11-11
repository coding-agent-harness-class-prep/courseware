# Interactive and Programmatic Use

You can work with the Copilot CLI in two ways, and most teams end up using both in the same week.
Interactively, you hold a conversation in a session: you ask, the agent proposes and acts, you approve
or steer, and the session remembers all of it. Programmatically, you hand the CLI one prompt with
`-p`, it works until it's finished, and it exits, which is the shape a PowerShell script or a CI job
needs. The harness underneath is identical; what changes is who's there to answer the approval
prompts.

---

## Starting a session

Change into the repository and run `copilot`. The first launch in a folder asks you to trust it
(chapter 1), and then you're at a prompt.

```powershell
cd C:\src\library-java
copilot                                    # or: copilot -C C:\src\library-java
copilot -i "Summarize how lending works"   # start interactive and run this prompt right away
```

Sessions are saved, so you can stop and come back. `copilot --continue` resumes the most recent one,
`copilot --resume` opens a picker, and `--resume` also accepts a session ID, an ID prefix, or a name.
Name a session up front with `-n` (or later with `/rename`) and resuming it becomes easy:

```powershell
copilot -n "late-fee tests"
copilot --resume="late-fee tests"
```

### Pointing the agent at things

Four prefixes do most of the work of adding context. They're the terminal's equivalent of the `#`
context items you used in VS Code chat.

| Prefix | Example | What it does |
|---|---|---|
| `@FILENAME` | `@src/main/java/com/example/library/fees/LateFeeCalculator.java` | Includes that file in the conversation |
| `#NUMBER` | `#42` | Pulls an issue or pull request into context |
| `!COMMAND` | `!.\mvnw.cmd test` | Runs the command in your shell, bypassing Copilot |
| `&` | `& Add XML doc comments to LoanPolicy` | Delegates the prompt to the cloud agent (chapter 5) |

Here's the same question for each library sample, Java first and then .NET:

```text
Explain how @src/main/java/com/example/library/fees/LateFeeCalculator.java applies policy LIB-12.
Explain how @src/Library.Domain/Fees/LateFeeCalculator.cs applies policy LIB-12.
```

When you just want to see the test output yourself, the `!` prefix is the quick route: `!dotnet test`
or `!.\mvnw.cmd test` runs directly, with no tool call and no approval prompt, because the agent isn't
involved.

---

## Standard, plan, and autopilot

**Shift+Tab** cycles the session between three modes. In *standard* mode the agent works step by
step and asks for approval according to your permission settings. In *plan* mode it creates an
implementation plan before coding, so you can read the approach, push back, and only then let it edit;
you can also type `/plan` followed by a request, or start with `copilot --plan`. In *autopilot* mode it
keeps going without waiting for you between steps, pausing after a set number of automatic
continuation messages (five by default, adjustable with `--max-autopilot-continues`). `/autopilot`
accepts an optional AI-credit limit through `--max-ai-credits`.

Of the three, plan mode is the one to build a habit around, because on an unfamiliar bug it costs you
a minute of reading and turns "the agent edited six files" into "the agent proposed touching six files
and you agreed to two of them".

A few keys you'll use constantly:

| Key | Effect |
|---|---|
| Shift+Tab | Cycle standard → plan → autopilot |
| Esc | Cancel; press it twice to interrupt the current turn |
| Ctrl+C | Cancel or clear the input; press it twice to exit |
| Ctrl+T | Show or hide the model's reasoning |
| Ctrl+O | Expand the timeline |

---

## Slash commands worth knowing

Type `/` at the prompt to see the full list, or run `copilot help commands` outside a session. The
list grows almost every week, so treat this table as the starting set rather than the whole menu.

| Command | What it does |
|---|---|
| `/model` | Select the model for this session, or `auto` to let Copilot pick |
| `/agent` | Browse and select agents, including your custom ones (`/agent [name]`) |
| `/instructions` | View and toggle the custom instruction files that loaded |
| `/env` | Show what loaded: instructions, MCP servers, skills, agents, hooks, plugins |
| `/plan` | Create an implementation plan before coding |
| `/diff` | Review the changes made in the current directory |
| `/review` | Run the code review agent on your changes |
| `/pr` | Show the current branch's pull request; `/pr create` opens one |
| `/rewind` | Rewind the last turn and revert its file changes |
| `/resume` | Switch sessions by local or cloud history ID, task ID, or name |
| `/usage` | Show this session's AI credit usage and token breakdown |
| `/context` | Show how much of the context window is in use |
| `/compact` | Summarize the conversation so far to free up context |
| `/clear` | Abandon this session and start fresh |

The CLI compacts the conversation on its own when the context window gets close to full (around 95%),
but `/compact` lets you choose the moment, and you can pass it a hint about what to keep.

---

## Switching models

`/model` opens the model picker for the current session. Next to each model it shows the per-token
cost for input, cached input, and output, because Copilot billing is now measured in **AI Credits**
metered by tokens (accounts still on the legacy billing platform see a request multiplier instead).
Choosing `auto` lets Copilot pick a model for each task, and Auto has routing profiles named
Efficiency, Balance, and Intelligence, which you can set with `--auto-tier` or `COPILOT_AUTO_TIER`.

You can also choose at launch, which is how scripts do it:

```powershell
copilot --model auto --reasoning-effort high
$env:COPILOT_MODEL = 'auto'      # the default for every run in this shell
```

`--reasoning-effort` takes `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, or `max`. The model
IDs themselves change as GitHub adds and retires models, so copy one from `/model` rather than from a
blog post. If your organization brings its own model endpoint, the CLI supports that too through
`COPILOT_PROVIDER_BASE_URL`, `COPILOT_PROVIDER_TYPE` (`openai`, `azure`, or `anthropic`),
`COPILOT_PROVIDER_API_KEY`, and `COPILOT_MODEL`; `copilot help providers` has the details.

`/usage` shows what the session has consumed so far, and the footer at the bottom of the screen shows
your remaining budget.

---

## Running a prompt non-interactively

`-p` (or `--prompt`) runs one prompt and exits when the agent is done. Nobody is there to answer an
approval prompt, so the CLI's help describes `--allow-all-tools` as required for non-interactive mode.
That sounds alarming until you meet the rule that makes it workable: **deny rules always win**, even
over `--allow-all-tools`. A script therefore says "approve everything except these", and lists the
exceptions with `--deny-tool` (chapter 3 covers the pattern syntax).

| Flag | What it does |
|---|---|
| `-p, --prompt <text>` | Run one prompt non-interactively and exit when it completes |
| `-s, --silent` | Print only the agent's response, with no stats |
| `--output-format json` | Emit JSONL, one JSON object per line |
| `--allow-all-tools` | Approve tool calls without asking (required in prompt mode) |
| `--deny-tool <pattern>` | Refuse matching tool calls, whatever else is allowed |
| `--model <model>`, `--agent <agent>` | Choose the model or a custom agent for the run |
| `--no-ask-user` | Don't let the agent stop to ask you a question |
| `--max-ai-credits <n>` | Set a maximum AI-credit spend for the session |
| `--trust-folder` | Trust the folder's own configuration for this one run |

Two cautions apply to scripts. First, the environment variable `COPILOT_ALLOW_ALL` does the same job
as `--allow-all-tools`, but setting it to exactly `"true"` *also* trusts the working directory, which
loads that folder's MCP servers and hooks. Prefer the explicit flag in anything you share. Second, the
words "don't change any files" in a prompt are a request to the model rather than a control, and it's
the deny rules that actually enforce it.

### A PowerShell script

This script drafts release notes for the current branch. The prompt asks for a read-only job, and the
deny rules back that request up for the actions that matter most.

```powershell
# release-notes.ps1: draft release notes for this branch without changing the working tree
$prompt = @'
Compare this branch with main using git log and git diff.
Write release notes as Markdown bullets grouped under Added, Changed, and Fixed.
Do not modify any files.
'@

$notes = copilot -p $prompt -s --allow-all-tools `
    --deny-tool='write' `
    --deny-tool='shell(git commit)' `
    --deny-tool='shell(git push)'

$notes | Set-Content -Path .\release-notes.md
```

`write` with no path refuses every built-in file create or edit. It doesn't cover shell commands,
which is why the script also denies `git commit` and `git push` by name, and a shell command could
still write a file; chapter 3 explains how the local sandbox's path policy limits that. In bash, the
flags are identical and only the line continuation changes (`\` instead of a backtick).

When another program needs to consume the run, switch to JSON output, which arrives as one JSON
object per line:

```powershell
copilot -p $prompt --output-format json --allow-all-tools --deny-tool='write' > .\run.jsonl
Get-Content .\run.jsonl | ForEach-Object { $_ | ConvertFrom-Json } | Select-Object -First 3
```

### In CI: an illustration

The workflow below is an **illustration, not a recommended pipeline**. It runs the library app's tests
and, only if they fail, asks Copilot to explain the failures in the job log. Its job is to explain,
not to change code or push, and every setting leans toward the minimum that job needs.

```yaml
# Illustration only: explain failing tests in the job log. Read-only by design.
name: CI
on: pull_request
permissions:
  contents: read                  # the job's own GITHUB_TOKEN can't write anything

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-java@v6
        with:
          distribution: temurin
          java-version: "21"
          cache: maven
      - name: Build and test
        run: sh ./mvnw -B verify

      - uses: actions/setup-node@v7      # the npm package needs Node.js 22 or later
        if: failure()
        with:
          node-version: "22"
      - name: Explain the failing tests
        if: failure()
        env:
          COPILOT_GITHUB_TOKEN: ${{ secrets.COPILOT_CLI_TOKEN }}
        run: |
          npm install -g @github/copilot
          copilot -p "Read target/surefire-reports and explain why each failing test failed." \
            -s --no-ask-user --allow-all-tools --disable-builtin-mcps \
            --deny-tool='write' --deny-tool='shell(git:*)' --deny-tool='shell(gh:*)'
```

The secret holds a fine-grained personal access token with the **Copilot Requests** permission, and
it reaches the CLI only through `COPILOT_GITHUB_TOKEN` in the one step that needs it. The deny rules
refuse file writes and every `git` and `gh` command, and `--disable-builtin-mcps` removes the built-in
GitHub tools, because explaining a test report needs neither. Auto-update is already off in CI, so the
run uses the version npm installed. For the .NET app, swap the Java steps for
`actions/setup-dotnet@v6` and `dotnet test`, and point the prompt at the test output.

Keep the threat model in mind before you go further than this. An agent reading pull request content
is reading input that someone else wrote, so the token's reach, the job's permissions, and the deny
list are what limit the damage if that input tries to steer it.

---

## Summary

- `copilot` starts an interactive session in the current folder; `--continue`, `--resume`, and `-n`
  bring sessions back by recency, picker, ID, or name.
- `@FILENAME`, `#NUMBER`, `!COMMAND`, and `&` add a file, add an issue or PR, run your own shell
  command, and delegate to the cloud agent.
- Shift+Tab cycles standard, plan, and autopilot; plan mode shows the approach before anything is
  edited.
- `/model` (or `--model`, `COPILOT_MODEL`) switches models and shows per-token costs in AI Credits;
  `/usage` and `/context` show what the session is consuming.
- `-p` runs one prompt and exits; add `-s` or `--output-format json` for scripts. Prompt mode needs
  `--allow-all-tools`, and `--deny-tool` rules, which always win, are how you keep it narrow.
