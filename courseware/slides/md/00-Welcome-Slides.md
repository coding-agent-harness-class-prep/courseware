---
title: GitHub Copilot as a Coding-Agent Harness
subtitle: Agentic development in VS Code, the Copilot CLI, and GitHub.com
author: Xebia
---

# Welcome

## What This Session Is

- A hands-on tour of GitHub Copilot as a **coding-agent harness**
- One agent loop, one set of tools and context files, one approval model
- Three places it runs: VS Code, the terminal, and GitHub.com
- You'll use all three on a real .NET or Java codebase
- We finish by comparing Copilot with OpenCode and Kiro

## Agenda

| Time | Block |
|---|---|
| 0:00 | Welcome and your practice repo |
| 0:10 | Module 1 — The harness and chat in VS Code |
| 1:00 | Module 2 — Agent mode, instructions, agents, MCP |
| 1:50 | Module 3 — The cloud agent and code review |
| 2:20 | Break |
| 2:30 | Module 3 activity, part 2 |
| 2:50 | Module 4 — The Copilot CLI |
| 3:40 | Conclusion and questions |

## How Each Module Runs

- 25 minutes of live demo on the **library** app
- 25 minutes of hands-on work on the **orders** app, in your own repo
- Each activity links its module's slides, for review whenever you like
- You won't finish every task, and that's by design
- Each activity has a `solution/` folder for afterward

## Two Apps, Two Languages

| App | What it does | Who uses it |
|---|---|---|
| Library | Books, loans, due dates, late fees | The instructor's demos |
| Orders | Catalog, validation, discounts, tax | Your activities |

- Each app exists in **.NET 10** and **Java 21**
- Pick the language you work in every day

## Your Environment

- A VM with VS Code, Git, the Copilot CLI, the .NET SDK, and a JDK
- The GitHub account you were given, with a Copilot seat
- Check it now (clone the courseware first if it isn't there):

```powershell
git clone https://github.com/coding-agent-harness-class/courseware $HOME\copilot-course
cd $HOME\copilot-course\courseware\setup
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -VerifyOnly
```

- Then sign in: Copilot in VS Code, `copilot` then `/login`, and `gh auth login`

## Make Your Practice Repo (1)

- Enterprise accounts can't fork from outside the enterprise, so you **copy** the app
- Your copy is a **private** repo in your own account
- Its Actions tab stays empty: personal repos of enterprise accounts don't run Actions
- Step by step: `courseware/setup/student-quick-start.md`
- Sign in `gh` first, with the `workflow` scope so you can push workflows:

```powershell
gh auth login --web --git-protocol https --scopes workflow
gh auth setup-git
```

## Make Your Practice Repo (2)

```powershell
$me = gh api user -q .login
$repo = "$me/orders-dotnet"
git clone https://github.com/coding-agent-harness-class/orders-dotnet $HOME\orders-dotnet
Set-Location $HOME\orders-dotnet
gh repo create $repo --private
git remote remove origin
git remote add origin "https://github.com/$repo.git"
git push -u origin main
gh repo set-default $repo
```

- Java: `orders-java` everywhere it says `orders-dotnet`
- Post your repo's link in the chat when it opens with `gh repo view --web`

## One Thing to Expect

- Copilot won't give you exactly what it gave the person next to you
- Different runs and different models take different paths
- The skill is reading what the agent did, judging it, and steering it
- Activity steps describe what you should **see**, not exact output

## Let's Begin

- Courseware: `README.md` at the root of the repository
- Activities: `courseware/activities/`
- Reference reading: `courseware/docs/`
- Questions any time, in the chat or out loud
