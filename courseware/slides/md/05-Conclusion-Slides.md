---
title: Copilot, OpenCode, and Kiro Side by Side
subtitle: GitHub Copilot as a Coding-Agent Harness
author: Xebia
---

# Copilot, OpenCode, and Kiro Side by Side

## Agenda

- Three harnesses at a glance
- Models and where they run
- Context: instruction files and MCP
- Approvals, sandboxing, and the path to a pull request
- What's open source
- Where Copilot stands out, and where it's constrained

## Three Harnesses at a Glance

| | Copilot | OpenCode | Kiro |
|---|---|---|---|
| Maker | GitHub | Anomaly | AWS |
| Surfaces | VS Code, CLI, app, GitHub.com | Terminal UI, desktop, web | IDE, CLI, Web, Mobile |
| Terminal command | `copilot` | `opencode` (v1 and v2) | `kiro-cli` |
| Windows install | WinGet `GitHub.Copilot` | Binary or npm | PowerShell script |

- Same loop in all three: model, tools, approvals, session state

## Models and Where They Run

| | Copilot | OpenCode | Kiro |
|---|---|---|---|
| Model list | GitHub's: 6 vendors + Auto | Any provider | Kiro's, by credit multiplier |
| Your key, or local | BYOK in VS Code, CLI, app | Yes, incl. Ollama | Not documented |
| Hosting | Vendor clouds, GitHub's Azure | Your provider or machine | AWS, US and EU regions |
| Billing | AI Credits, token-metered | Your provider's bill | Monthly credits by tier |

## Context: Instructions and MCP

| | Copilot | OpenCode 2 | Kiro |
|---|---|---|---|
| Instructions | `copilot-instructions.md` and more | `AGENTS.md` only | `.kiro/steering/*.md` |
| `AGENTS.md` | Read; nearest wins | The only file | Always included |
| Custom agents | `.github/agents/` | `.opencode/agents/` | `.kiro/agents/` |
| MCP file | `.mcp.json` | `opencode.json` | `.kiro/settings/mcp.json` |
| MCP key | `mcpServers` | `mcp.servers` | `mcpServers` |

- `AGENTS.md` is the one file all three read

## Approvals, Sandbox, and the PR

| | Copilot | OpenCode | Kiro |
|---|---|---|---|
| Approvals | Prompts, allow/deny, modes | allow / ask / deny rules | Autopilot or Supervised; rules |
| Local sandbox | Yes, off by default | None | Yes, off by default |
| Task to PR | Assign issue → draft PR | Local `git` and `gh` | `kiro` label or `/kiro` |
| Cloud runs | Actions or cloud sandbox | Action removed in v2.2.0 | Kiro Web sandbox |

## What's Open Source

| | Open source | Not open source |
|---|---|---|
| Copilot | VS Code + chat, SDK, MCP server | CLI, app, cloud agent, models |
| OpenCode | The whole agent (MIT) | Console, Go, Models |
| Kiro | Kiro Crew (Apache-2.0) | IDE, CLI, Web |

## Where Copilot Stands Out

- One harness from VS Code to the terminal to GitHub.com
- Issue to draft PR with CodeQL, secret and dependency checks
- Copilot code review as a built-in second opinion
- Six model vendors and Auto from one subscription
- Same instructions, agents, and MCP config across surfaces
- Org policy and MCP allowlists enforced in app, CLI, VS Code

## Where Copilot Is Constrained

- Cloud agent: GitHub-hosted repositories only
- Actions sessions: one repo, 59-minute cap (issue assignment too)
- Cloud sandboxes span one org's repos, but skip setup steps
- One branch and one pull request per task
- Model menu set by GitHub; no BYOK in the cloud agent
- CLI, app, and agent services are proprietary
- Two meters: AI Credits plus Actions compute

## Choosing for Your Team

- Copilot: code on GitHub; want issue to PR with checks built in
- OpenCode: need open source, any provider, or local models
- Kiro: spec-driven work, AWS hosting, or GitLab for cloud work
- OpenCode has no sandbox; Copilot's and Kiro's are off by default
- Keep conventions in `AGENTS.md` to stay portable

## Key Takeaways

- All three run the same loop: model, tools, approvals
- They differ in who picks the model and where it runs
- `AGENTS.md` is the portable instruction file
- Copilot's edge is GitHub itself: issues, PRs, checks, review
- Its limits: GitHub-hosted repos, GitHub's menu, closed services
