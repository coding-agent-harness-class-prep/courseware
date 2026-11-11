# Student Machine and Account Setup — GitHub Copilot as a Coding-Agent Harness

This is the one-page checklist for the team preparing the session's environment. The session needs two
things ready before it starts: **one virtual machine per participant** and **a GitHub account per
participant** with a Copilot seat whose agent features are turned on. Please have both in place, and
one test account checked end to end, at least two working days before the session.

## 1. Software on each participant VM

| Software | Version | Windows (winget ID) |
|---|---|---|
| Visual Studio Code | current | `Microsoft.VisualStudioCode` |
| Git | current | `Git.Git` |
| GitHub Copilot CLI | current | `GitHub.Copilot` |
| PowerShell 7 (Windows only; the Copilot CLI needs PowerShell 6 or later) | 7.x | `Microsoft.PowerShell` |
| .NET SDK | 10.0 | `Microsoft.DotNet.SDK.10` |
| JDK | 21 or later | `EclipseAdoptium.Temurin.21.JDK` (or any JDK 21+) |
| GitHub CLI (`gh`); the Copilot CLI uses it to open pull requests | current | `GitHub.cli` |

**VS Code extensions:** C# Dev Kit (`ms-dotnettools.csdevkit`), Extension Pack for Java
(`vscjava.vscode-java-pack`), and GitHub Pull Requests (`github.vscode-pull-request-github`). GitHub
Copilot Chat has been built into VS Code since version 1.116, so there's no Copilot extension to install.

Maven and Gradle are **not** needed: the Java samples use the Maven Wrapper, which downloads Maven on
first use.

**Windows Server VMs are fine.** They run everything in the course except the Copilot CLI's local
sandbox, which needs Windows 11 version 25H2 with update KB5124010 or later, or version 26H1 with
KB5124006 or later. The instructor demonstrates the sandbox from their own machine, so nothing extra
is needed on the VMs.

**A clone of this courseware repository**, `https://github.com/coding-agent-harness-class/courseware`,
at `%USERPROFILE%\copilot-course` on each VM saves time at the start, and the activities' copy commands expect it there. Participants don't work in it: they copy
a published sample app into a private repository in their own account (section 3) and copy only
a few files from the courseware into that repository. If it isn't pre-cloned, participants clone it themselves during the welcome.

The course's [`setup.ps1`](setup.ps1) installs all of this with winget and is safe to run more than once
(`-VerifyOnly` reports what's present without installing). [`setup.sh`](setup.sh) does the same on
macOS (Homebrew) and Debian/Ubuntu (apt).

**Before imaging,** run `pwsh -File ..\utils\build-all.ps1 -Path 'samples/*'` from this folder once,
signed in as the account participants will use. It restores every NuGet and Maven package the samples
use into that user's caches, so the class doesn't download them all at once. (Without `-Path` it also
tries the course's Node.js test harness, which the VMs don't need.)

## 2. Network access from the VMs

Allow outbound HTTPS to:

- **GitHub and Copilot:** `github.com`, `*.github.com` (which covers `api.github.com`),
  `*.githubusercontent.com`, `github.githubassets.com`, `*.githubcopilot.com`, and `gh.io`. GitHub's
  [Copilot allowlist reference](https://docs.github.com/en/copilot/reference/copilot-allowlist-reference)
  has the full list.
- **VS Code and its extensions:** `update.code.visualstudio.com`, `marketplace.visualstudio.com`,
  `*.gallery.vsassets.io`, `*.gallerycdn.vsassets.io`, `*.vscode-cdn.net`,
  `vscode.download.prss.microsoft.com`, and `download.visualstudio.microsoft.com` (the C# extension
  downloads its .NET components from there). VS Code's
  [network page](https://code.visualstudio.com/docs/setup/network) lists the rest.
- **Packages:** `api.nuget.org`, `*.nuget.org`, `repo.maven.apache.org`, `repo1.maven.org`

If traffic is inspected by a proxy, the proxy's certificate must be trusted by Git, the Copilot CLI, the
.NET SDK, and the JDK.

## 3. GitHub accounts and Copilot

The instructor publishes the course's sample applications as **public repositories**. Participants
use enterprise accounts, which can't fork a repository from outside their enterprise, so at the start
of the session each one clones a sample, creates a **private repository in their own account**,
pushes the clone there, and works in it all day. That needs:

- [ ] **Managed users allowed to create repositories in their own accounts.** If the enterprise blocks
      that, participants can still do Modules 1 and 2 and most of Module 4 in a local clone.
- [ ] **A Copilot Business or Enterprise seat** for every participant and the instructor.

GitHub Actions and the Copilot cloud agent don't run in the personal repositories of managed user
accounts, so participants don't run CI, the cloud agent, or `/delegate` themselves; the instructor
demonstrates them. Putting the practice repositories in an organization in the enterprise would make
them hands-on, but in an enterprise that only has Copilot Business, every member of an organization
also consumes a GitHub Enterprise Cloud license.

Then, in the enterprise's Copilot policies:

- [ ] The **Copilot in the cloud** policy enabled. It covers the Copilot cloud agent and cloud-sandbox
      sessions (which Module 4 starts from the terminal), and it's on by default for licensed members
      unless the enterprise has turned it off.
- [ ] The **Copilot code review** policy enabled.
- [ ] The **Copilot CLI** policy enabled.
- [ ] The **MCP servers in Copilot** policy enabled (the session uses the GitHub MCP server).
- [ ] At least two models enabled on the Copilot **Models** page, ideally one small and fast and one
      larger, so participants can compare them.
- [ ] Optional: **Allow Claude coding agent** and **Allow Codex coding agent** (both in public
      preview), if you'd like third-party agents shown in Module 3.

Copilot code review still works on participants' pull requests; without Actions it gives a lighter
review than in an organization, and managed user accounts can't turn on automatic review for their own
pull requests. The samples contain nothing sensitive. The instructor can't see participants' private
repositories, so a participant who needs hands-on help shares their screen.

Usage is billed in AI Credits. Each Business seat adds 1,900 credits ($19) a month to a pool the whole
organization shares, and each Enterprise seat adds 3,900 ($39); inline code completions don't draw on
it. The **AI credits paid usage** policy is on by default, so anything beyond the pool is billed to the
organization. If it's been turned off and the pool runs out, chat and agent requests are blocked until
the pool refreshes on the first of the month, so check it isn't nearly spent before the session.
Cloud-sandbox sessions are billed by usage (compute, memory, and storage).

## 4. A quick end-to-end check

With one test account on one VM, and the instructor's public sample repositories already published:

1. In VS Code, sign in to GitHub and ask Copilot Chat a question.
2. In a terminal, run `copilot`, then `/login`, then ask it a question.
3. Copy one of the sample repositories into a private repository in the test account, following
   [the student quick start](student-quick-start.md). Push a small change on a branch, open a pull
   request, and request a review from **Copilot** on it.

If all three work, the environment is ready. Step 3 is the one that matters most, because it's the
only way to confirm that managed users can create personal repositories and get Copilot reviews under
these seats. Questions about this checklist can go to the instructor.
