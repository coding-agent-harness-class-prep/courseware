# Setup

Your session VM should arrive with everything installed. This page tells you how to check it in two
minutes, how to sign in, and how to install the tools yourself if you're using your own machine. To
sign in and make your practice repo in one pass, follow the [quick start](student-quick-start.md).

---

## Get the courseware

The activities copy a few files from this courseware into your practice repo, and their commands
expect it at `$HOME\copilot-course`. If your VM doesn't already have it there, clone it from
[`coding-agent-harness-class/courseware`](https://github.com/coding-agent-harness-class/courseware):

```powershell
git clone https://github.com/coding-agent-harness-class/courseware $HOME\copilot-course
```

You don't work in this clone; it's the reference copy you copy from. (No Git yet on your own machine?
Download the repository as a ZIP from GitHub and extract it to the same folder.)

## Check your machine

From `$HOME\copilot-course\courseware\setup`:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -VerifyOnly
```

On macOS or Linux:

```bash
./setup.sh --verify-only
```

**Expected:** a line for each tool (`code`, `git`, `gh`, `copilot`, `dotnet`, `java`, `pwsh` on
Windows, and the VS Code extensions), each with a version, followed by *"Everything this course needs
is installed."* If something is listed as missing, run the script again without `-VerifyOnly` to
install it.

## Sign in

1. In VS Code, hover over the **Copilot** icon in the Status Bar and choose **Use AI Features**, then
   sign in with the GitHub account you were given for the session. Open the Chat view
   (**Ctrl+Alt+I**) and ask it anything to confirm it answers.
2. For the Copilot CLI, run `copilot` in a terminal. If it asks you to sign in, type `/login` and finish
   the sign-in in the browser window it opens. Type `/exit` to leave.
3. For the GitHub CLI and Git, run `gh auth login --web --git-protocol https --scopes workflow` and
   then `gh auth setup-git`, so Git pushes with the same sign-in. The `workflow` scope lets you push
   the sample's workflow files to your practice repo. Don't skip this one: in Module 4 the Copilot CLI opens your pull request with
   `gh pr create`, and `gh auth status` should show you signed in before then.

## Installing the tools yourself

If you're not using a session VM, the scripts in this folder install everything:

| Platform | Command |
|---|---|
| Windows | `powershell -ExecutionPolicy Bypass -File .\setup.ps1` |
| macOS (Homebrew) or Debian/Ubuntu (apt) | `./setup.sh` |

They install Visual Studio Code, Git, the GitHub CLI, the GitHub Copilot CLI, the .NET 10 SDK, a JDK 21,
and (on Windows) PowerShell 7, which the Copilot CLI needs. They then add the C# Dev Kit, Extension Pack
for Java, and GitHub Pull Requests extensions to VS Code. Copilot Chat is already built into VS Code.
Both scripts skip anything that's already installed, so it's safe to run them again. `-DryRun` /
`--dry-run` shows what they'd do without doing it.

If the script ends with **"ACTION REQUIRED - open a NEW terminal"** (exit code 3), nothing went wrong:
close the terminal, open a new one, and run it again so the new tools are on your PATH.

Maven isn't needed. The Java samples use the Maven Wrapper (`mvnw`), which downloads Maven the first
time you run it.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `copilot` says PowerShell 6 or later is required | Install PowerShell 7 (`winget install Microsoft.PowerShell`) and open a new terminal |
| Copilot Chat in VS Code says you have no access | You're signed in with a different account from the one you were given, or its Copilot seat isn't assigned yet. Tell the instructor. |
| `dotnet test` fails restoring packages | Your network can't reach `api.nuget.org`. Tell the instructor. |
| `.\mvnw.cmd` can't download Maven | Your network can't reach `repo.maven.apache.org`. Tell the instructor. |
| `java` isn't found after installing the JDK | Open a new terminal. If it's still missing, rerun the setup script. |

For the team preparing the VMs and the GitHub organization, see
[`setup-student-machines.md`](setup-student-machines.md).
