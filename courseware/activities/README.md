# Activities

Four hands-on activities, one per module, each timeboxed to **25 minutes**. They all run against
**your own copy** of the orders sample app, in .NET ([`orders-dotnet`](../samples/orders-dotnet/)) or
Java ([`orders-java`](../samples/orders-java/)), whichever you work in. Make that copy during the
welcome: [Make your practice repo](../samples/README.md#make-your-practice-repo-do-this-during-the-welcome).

## Activity List

1. [Chat with Workspace Context](01_chat-with-context/README.md) — Module 1: map and explain
   unfamiliar code with chat, then generate and run a unit test
2. [Agent Mode with Instructions and a Custom Agent](02_agent-mode-and-instructions/README.md) —
   Module 2: a validation rule in agent mode, run with and without repository instructions
3. [Turn an Issue into a Pull Request and Review It with Copilot](03_cloud-agent-and-review/README.md)
   — Module 3: issue → agent mode on a branch → pull request → Copilot code review, compared with the
   cloud agent's pull request from the demo
4. [Fix a Reported Bug from the Terminal with the Copilot CLI](04_copilot-cli/README.md) — Module 4:
   diagnose, fix, test, and open a PR from the terminal

## How an activity folder is laid out

| Path | What it holds |
|---|---|
| `README.md` | The tasks. Work through them in order; the first few carry the idea, later ones go deeper. |
| `assets/dotnet/`, `assets/java/` | Files you copy **into** your repository (Activities 02–04). Each mirrors the repository's own layout, so a file goes to the same relative path. |
| `issues/dotnet.md`, `issues/java.md` | Pre-written issue bodies to paste into a new GitHub issue (Activities 03 and 04). |
| `solution/dotnet/`, `solution/java/` | A reference result, laid out the same way. Copilot's output will differ from it; compare what it covers, not how it's written. |

## They build on one repository

The activities share your practice repo on purpose. The customization files you add in Activity 02
(`.github/copilot-instructions.md`, a path-scoped instructions file, a custom agent, and `.mcp.json`) are committed
and pushed, and then agent mode and Copilot code review in Activity 03 and the CLI in Activity 04 read
them unchanged. That's the course's main point: one harness, one set of customization files, three
places it runs. (Your enterprise account's personal repositories can't run the cloud agent, the third
place, so you see it in the demos.)

If you fall behind, you can still start any activity from your practice repo: run the
[catch-up commands](../samples/README.md#if-you-fall-behind), which copy
[`02_agent-mode-and-instructions/assets/<language>/`](02_agent-mode-and-instructions/assets/) into it,
commit, and push, so the later activities find the files they expect.

## Copilot won't do exactly what the README says

The steps describe what you should *see*, not exact output. Models differ between runs, between model
choices, and from week to week as the product updates. When the result differs, that's part of the
lesson: read what the agent did, decide whether it's right, and steer it. Each `solution/` is one good
answer, checked by the course's validation harness to build and pass its tests.
