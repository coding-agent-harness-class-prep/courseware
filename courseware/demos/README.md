# Demos

Four instructor demos, one per module, each paired with the activity of the same number. A demo is
the module's whole 25-minute lesson, taught live without slides: its trail takes about 15 minutes, and
the rest goes to explaining the concepts as they come up, questions, and waiting on the agent. Each
demo runs on the **library** sample app. The paired activity applies the same idea to the **orders** app, so students
practice on code they haven't watched you change.

| # | Demo | Module | Concept | Sample (language) | Paired activity |
|---|---|---|---|---|---|
| 01 | [The Harness and Chat That Knows the Project](01_harness-and-chat/README.md) | 1 | Model vs harness; chat with context; `/explain`, `/tests`; model choice | `library-dotnet` (.NET) | [01 — Chat with Workspace Context](../activities/01_chat-with-context/README.md) |
| 02 | [Agent Mode, Instructions, Custom Agents, and MCP](02_agent-mode-customization/README.md) | 2 | Agent mode with approvals; instructions measured with and without; custom agent; MCP | `library-java` (Java) | [02 — Agent Mode with Instructions and a Custom Agent](../activities/02_agent-mode-and-instructions/README.md) |
| 03 | [The Cloud Agent and Copilot Code Review](03_cloud-agent-code-review/README.md) | 3 | Issue → cloud agent → session log and its security checks → draft PR; code review, automatic review; `@copilot` | `library-dotnet` (.NET) | [03 — Turn an Issue into a Pull Request and Review It with Copilot](../activities/03_cloud-agent-and-review/README.md) |
| 04 | [The GitHub Copilot CLI](04_copilot-cli/README.md) | 4 | Same customizations in the terminal; the local sandbox; plan mode; approvals; PR from the terminal; `/delegate` and back | `library-java` (Java) | [04 — Fix a Reported Bug from the Terminal with the Copilot CLI](../activities/04_copilot-cli/README.md) |

The demos alternate languages so both halves of the audience see their own stack. Each demo's
`solution/` folder, and its `assets/` folder where it has one, holds both a `dotnet/` and a `java/`
version, so you can run any demo in either language to suit the room.

## Running a demo

Demos 02–04 run in clones of three demo repositories in `coding-agent-harness-class`, each a copy of a
library sample set up for its demo:

| Repository | Used by | What's in it |
|---|---|---|
| [`library-demo-java`](https://github.com/coding-agent-harness-class/library-demo-java) | Demos 02 and 04 | `samples/library-java` as it ships, with no customization files |
| [`library-demo-dotnet`](https://github.com/coding-agent-harness-class/library-demo-dotnet) | Demo 03 | `samples/library-dotnet` plus Demo 02's .NET customization files, and the demo's three issues |
| [`library-demo-dotnet-backup`](https://github.com/coding-agent-harness-class/library-demo-dotnet-backup) | Demo 03 | The same start, plus a draft pull request built from Demo 03's `solution/` |

Clone all three before class. Every demo's instructions assume these folders:

```powershell
New-Item -ItemType Directory -Force $HOME\demo | Out-Null
Set-Location $HOME\demo
gh repo clone coding-agent-harness-class/library-demo-java
gh repo clone coding-agent-harness-class/library-demo-dotnet
gh repo clone coding-agent-harness-class/library-demo-dotnet-backup
```

Demo 01 needs no repository on GitHub: it runs on a local copy of `samples/library-dotnet`, and its
**Before class** section makes it. Never run a demo in `courseware/samples/` itself.

Between rehearsals, `git reset --hard` and `git clean -fd` in a clone get you back to the start. A reset
only undoes what's on your machine, though: if a rehearsal pushed or created something on GitHub,
recreate that repository (below). Each demo's **Before class** section lists exactly what to set up and
when (Demo 03's two cloud runs have to start at least 30 minutes ahead, and Demo 04 needs a finished
cloud-sandbox session to bring back).

### Creating or recreating the demo repositories

You only need this the first time, or after a rehearsal changed a repository on GitHub. Rehearse in a
separate organization if you can, because Demo 02's last two steps and Demo 03's last two steps can't be
undone. To recreate a repository, delete it and your clone of it first (shown here for
`library-demo-java`; use the name of the one you're recreating):

```powershell
gh auth refresh -s delete_repo        # once, so gh may delete repositories
gh repo delete coding-agent-harness-class/library-demo-java --yes
Remove-Item -Recurse -Force $HOME\demo\library-demo-java
```

Then run its block from the root of your courseware clone. Each one leaves a clone in `$HOME\demo`.

`library-demo-java`:

```powershell
$course = (Get-Location).Path
Copy-Item -Recurse "$course\courseware\samples\library-java" $HOME\demo\library-demo-java
Set-Location $HOME\demo\library-demo-java
git init -b main; git add .; git commit -m "Demo start"
gh repo create coding-agent-harness-class/library-demo-java --public --source . --push
```

`library-demo-dotnet`, with Demo 03's three issues (they come out as #1, #2, and #3):

```powershell
$course = (Get-Location).Path
$demo03 = "$course\courseware\demos\03_cloud-agent-code-review"
Copy-Item -Recurse "$course\courseware\samples\library-dotnet" $HOME\demo\library-demo-dotnet
Copy-Item -Recurse -Force "$course\courseware\demos\02_agent-mode-customization\assets\dotnet\*" $HOME\demo\library-demo-dotnet
Set-Location $HOME\demo\library-demo-dotnet
git init -b main; git add .; git commit -m "Demo start with Copilot customization"
gh repo create coding-agent-harness-class/library-demo-dotnet --public --source . --push
gh issue create --title "List overdue loans" --body-file "$demo03\issues\dotnet.md"
gh issue create --title "Export a member's loan history" --body-file "$demo03\issues\dotnet-loan-export.md"
gh issue create --title "Show a member's total fines" `
    --body "Add an endpoint that returns the total late fees a member owes across all of their loans."
```

`library-demo-dotnet-backup`, with its draft pull request:

```powershell
$course = (Get-Location).Path
Copy-Item -Recurse "$course\courseware\samples\library-dotnet" $HOME\demo\library-demo-dotnet-backup
Copy-Item -Recurse -Force "$course\courseware\demos\02_agent-mode-customization\assets\dotnet\*" $HOME\demo\library-demo-dotnet-backup
Set-Location $HOME\demo\library-demo-dotnet-backup
git init -b main; git add .; git commit -m "Demo start with Copilot customization"
gh repo create coding-agent-harness-class/library-demo-dotnet-backup --public --source . --push
git switch -c list-overdue-loans
Copy-Item -Recurse -Force "$course\courseware\demos\03_cloud-agent-code-review\solution\dotnet\*" .
git add .; git commit -m "List overdue loans"; git push -u origin list-overdue-loans
gh pr create --draft --title "List overdue loans" --body "Backup copy of the cloud agent's work."
```

## When the live run goes somewhere else

Model output varies between runs, so every demo README has an **If Copilot does something different**
section, and every demo has a `solution/` folder with a reference result you can drop in to keep the
session moving. The validation harness proves each one builds and passes its tests, and proves that
each repro test fails for the reason the issue describes.
