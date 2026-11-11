# Course Map — GitHub Copilot as a Coding-Agent Harness

This is the join table for the whole course: every outline section and bullet resolved to the doc
chapter that explains it, the slide deck that summarizes it, the demo step that teaches it, the activity
task that practices it, and the diagram that draws it. View A reads by module; View B reads by concept.
For *when* each piece is taught, see the [teaching guide](TEACHING-GUIDE.md).

> **Keeping it honest.** When you add, remove, rename, or renumber a chapter, deck, demo, activity, or
> diagram, update this file in the same change, and check the counts table at the bottom against the
> file system. The `validations/` harness checks that every link here resolves.

---

## A · By module

| Module | Outline § | Docs folder | Slide deck | Demo | Activity | Diagrams |
|---|---|---|---|---|---|---|
| Welcome | — | — | [`00-Welcome-Slides`](../slides/md/00-Welcome-Slides.md) | — | [Make your practice repo](../samples/README.md#make-your-practice-repo-do-this-during-the-welcome) | — |
| 1 | Module 1 | [`01_copilot-harness-and-chat`](../docs/01_copilot-harness-and-chat/) | [`01-Copilot-Harness-and-Chat-Slides`](../slides/md/01-Copilot-Harness-and-Chat-Slides.md) | [01](../demos/01_harness-and-chat/README.md) (.NET) | [01](../activities/01_chat-with-context/README.md) | 01, 02, 03, 04 |
| 2 | Module 2 | [`02_agent-mode-instructions-agents-mcp`](../docs/02_agent-mode-instructions-agents-mcp/) | [`02-Agent-Mode-Instructions-Agents-MCP-Slides`](../slides/md/02-Agent-Mode-Instructions-Agents-MCP-Slides.md) | [02](../demos/02_agent-mode-customization/README.md) (Java) | [02](../activities/02_agent-mode-and-instructions/README.md) | 05, 06, 07 |
| 3 | Module 3 | [`03_cloud-agent-and-code-review`](../docs/03_cloud-agent-and-code-review/) | [`03-Cloud-Agent-and-Code-Review-Slides`](../slides/md/03-Cloud-Agent-and-Code-Review-Slides.md) | [03](../demos/03_cloud-agent-code-review/README.md) (.NET) | [03](../activities/03_cloud-agent-and-review/README.md) | 08 |
| 4 | Module 4 | [`04_copilot-cli`](../docs/04_copilot-cli/) | [`04-Copilot-CLI-Slides`](../slides/md/04-Copilot-CLI-Slides.md) | [04](../demos/04_copilot-cli/README.md) (Java) | [04](../activities/04_copilot-cli/README.md) | 09, 10 |
| Conclusion | Conclusion | [`05_conclusion`](../docs/05_conclusion/) | [`05-Conclusion-Slides`](../slides/md/05-Conclusion-Slides.md) | — | — | — |

---

## B · By concept

Demo and activity columns name the step or task where the concept is shown or practiced.

### Module 1 — The Copilot harness and chat in VS Code

| § | Concept | Doc chapter | Demo 01 | Activity 01 | Diagram |
|---|---|---|---|---|---|
| A | Model versus harness; one harness on every surface | [01 Model versus harness](../docs/01_copilot-harness-and-chat/01_model-versus-harness.md) | Steps 1, 6 | — | [01](../diagrams/png/01-model-vs-harness.png), [02](../diagrams/png/02-one-harness-four-surfaces.png) |
| B | The capability ladder | [02 The capability ladder](../docs/01_copilot-harness-and-chat/02_the-capability-ladder.md) | Step 1 | — | [03](../diagrams/png/03-capability-ladder.png) |
| C | Chat with project context; built-in actions | [03 Chat that knows the project](../docs/01_copilot-harness-and-chat/03_chat-that-knows-the-project.md) | Steps 2–4 | Tasks 1–3, 5 | [04](../diagrams/png/04-context-assembly.png) |
| D | Model selection and Auto | [04 Choosing a model](../docs/01_copilot-harness-and-chat/04_choosing-a-model.md) | Step 5 | Task 4 | — |

### Module 2 — Agent mode with instructions, custom agents, and MCP

| § | Concept | Doc chapter | Demo 02 | Activity 02 | Diagram |
|---|---|---|---|---|---|
| A | Agent mode, tools, approvals, the session log | [01 Agent mode](../docs/02_agent-mode-instructions-agents-mcp/01_agent-mode.md) | Steps 1–2 | Tasks 1–2 | [05](../diagrams/png/05-agent-mode-loop.png) |
| B | Repository and path-scoped instructions, `AGENTS.md` | [02 Repository instructions](../docs/02_agent-mode-instructions-agents-mcp/02_repository-instructions.md) | Steps 3–4 | Task 3 | [06](../diagrams/png/06-instruction-files.png) |
| C | Custom agents under `.github/agents` | [03 Custom agents](../docs/02_agent-mode-instructions-agents-mcp/03_custom-agents.md) | Step 5 | Task 4 | — |
| D | MCP servers | [04 MCP servers](../docs/02_agent-mode-instructions-agents-mcp/04_mcp-servers.md) | Step 6 | Task 5 | [07](../diagrams/png/07-mcp-architecture.png) |

### Module 3 — GitHub.com, the cloud agent and code review

| § | Concept | Doc chapter | Demo 03 | Activity 03 | Diagram |
|---|---|---|---|---|---|
| A | The cloud agent, the Agents tab, the Actions environment, the PR | [01 The Copilot cloud agent](../docs/03_cloud-agent-and-code-review/01_the-cloud-agent.md) | Steps 1–2, 5 | Task 6 (compares with the demo's pull request) | [08](../diagrams/png/08-cloud-agent-flow.png) |
| B | Inside a cloud run: validation and the session log | [02 Inside a cloud run](../docs/03_cloud-agent-and-code-review/02_inside-a-cloud-run.md) | Steps 3–4 | Task 6 (the demo's pull request) | [08](../diagrams/png/08-cloud-agent-flow.png) |
| C | Steering: actionable issues, custom agents, Spaces, Memory | [03 Steering the cloud agent](../docs/03_cloud-agent-and-code-review/03_steering-the-cloud-agent.md) | Steps 2, 7 | Tasks 1–2 | — |
| D | Copilot code review and custom review instructions | [04 Copilot code review](../docs/03_cloud-agent-and-code-review/04_copilot-code-review.md) | Step 6 | Task 5, Stretch 1 | — |
| E | Pull request summaries and Chat on GitHub.com | [05 Pull request summaries, Chat, and other agents](../docs/03_cloud-agent-and-code-review/05_pr-summaries-chat-and-other-agents.md) | Step 8 | Task 6, Stretch 2 | — |
| F | Other coding agents in the Agents panel | [05 Pull request summaries, Chat, and other agents](../docs/03_cloud-agent-and-code-review/05_pr-summaries-chat-and-other-agents.md) | Closing note | — | — |

### Module 4 — The GitHub Copilot CLI

| § | Concept | Doc chapter | Demo 04 | Activity 04 | Diagram |
|---|---|---|---|---|---|
| A | What the CLI is, `gh` vs `copilot`, installation | [01 What the Copilot CLI is](../docs/04_copilot-cli/01_what-the-cli-is.md) | Step 1 | Prerequisites | — |
| B | Interactive and programmatic use | [02 Interactive and programmatic use](../docs/04_copilot-cli/02_interactive-and-programmatic-use.md) | Steps 2–3, 8 | Tasks 2–3, Stretch 2 | — |
| C | Permissions, allow/deny rules, the sandbox | [03 Permissions and the sandbox](../docs/04_copilot-cli/03_permissions-and-sandbox.md) | Steps 2, 4–5, 8 | Tasks 2, 4, Stretch 3 | [09](../diagrams/png/09-cli-permissions.png) |
| D | GitHub integration and MCP servers | [04 GitHub integration and MCP servers](../docs/04_copilot-cli/04_github-integration-and-mcp.md) | Steps 3, 6 | Tasks 3, 5 | — |
| E | Reusing the Module 2 customization files | [05 Reusing customizations, second opinions, and handoffs](../docs/04_copilot-cli/05_reusing-customizations-and-handoffs.md) | Step 2 | Task 2 | — |
| F | Review agent, `/delegate`, continuing a cloud session | [05 Reusing customizations, second opinions, and handoffs](../docs/04_copilot-cli/05_reusing-customizations-and-handoffs.md) | Step 7 | Stretch 1, 3 | [10](../diagrams/png/10-cli-cloud-handoff.png) |

### Conclusion

| § | Concept | Doc chapter |
|---|---|---|
| A | Copilot, OpenCode, and Kiro side by side | [01 Three harnesses side by side](../docs/05_conclusion/01_three-harnesses-side-by-side.md) |
| B–C | Where Copilot stands out and where it's constrained | [02 Where Copilot stands out, and where it's constrained](../docs/05_conclusion/02_where-copilot-stands-out-and-where-it-is-constrained.md) |

---

## Counts

| Artifact | Count |
|---|---|
| Outline sections | 5 (four modules and the conclusion) |
| Doc modules | 5 |
| Doc chapters | 20 |
| Slide decks | 6 (welcome, four modules, conclusion) |
| Demos | 4 |
| Activities | 4 |
| Sample apps | 4 (two domains × .NET and Java) |
| Pre-written issues | 10 (five issues × two languages) |
| Diagrams | 10 |
| Exit tickets | 0 (none by design for a four-hour session) |
