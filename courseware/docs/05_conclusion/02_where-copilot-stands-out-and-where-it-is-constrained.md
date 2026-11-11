# Where Copilot Stands Out, and Where It's Constrained

After four modules on one product, it's fair to ask what you'd gain and what you'd give up by choosing
it as your team's harness. The answer depends less on any single feature than on where your code
lives and how much control you need over the model and the software around it. What follows is
Copilot's case and its limits, each set against what OpenCode and Kiro do, so you can weigh them with
the comparison from the previous chapter in hand.

---

## Where Copilot stands out

### One harness across the IDE, the terminal, and GitHub.com

The same agent runtime, the one the Copilot SDK exposes, sits behind VS Code's default Copilot
harness, the Copilot CLI, and the Copilot app, and GitHub says its cloud sessions have the same tools
as the CLI and the app. You saw the payoff in Module 4, where a session that started in your terminal
went to the cloud agent with `/delegate`, and a cloud-sandbox session came back to the terminal with
"Continue in Copilot CLI". Sessions move the same way between VS Code, the app, the CLI, GitHub.com,
and Mobile.

Kiro makes the same claim for its IDE, CLI, and Kiro Web, so a unified harness alone isn't unique.
What's distinctive is that Copilot's third surface is GitHub.com itself, where your issues, pull
requests, Actions workflows, branch protection, and security tooling already live, so the agent works
inside your forge rather than connecting to it from outside.

### An issue-to-pull-request flow with review and scanning built in

Assigning an issue to Copilot produces a draft pull request without anyone opening an editor, and the
run checks its own work before it asks for review. By default every cloud run includes CodeQL, secret
scanning, a check of new dependencies against the GitHub Advisory Database, and a Copilot code review
(administrators can choose which of these tools run), and none of it requires an Advanced Security
license. The guardrails around that flow are part of the platform: only users with write access can
trigger the agent, workflows on its pull requests don't run until someone approves them, the person
who asked for the pull request can't approve it, and the commits are authored by Copilot with the
requester as co-author.

Copilot code review also works on any pull request, including ones people wrote. It reads the
repository's instructions and `REVIEW.md` from the head branch, and leaves comments by default.
Approving pull requests became generally available in October 2026, but it stays off until an admin
turns it on. Review can also hand a comment to the cloud agent with "Fix with Copilot", which is still
in preview.

Kiro Web's autonomous mode also opens pull requests from labeled issues, and its `/kiro fix` command
acts on review feedback. OpenCode no longer has a supported path here, having removed its GitHub
Action in v2.2.0. The built-in security validation is the part with no documented equivalent in
either.

### A model picker spanning several vendors

From one subscription you can choose among models from OpenAI, Anthropic, Google, Microsoft, Moonshot,
and xAI, or let Auto pick, and GitHub publishes where each vendor's models are hosted and under what
retention terms. For a team that wants to try a different model on a hard bug without signing a new
vendor contract, that's convenient.

As curated lists go it's a broad one, but it isn't the widest choice of the three. OpenCode lets you
bring any provider, including a model running on your own machine, and Kiro's list spans OpenAI,
Anthropic, and several open-weight models too.

### Customizations shared across surfaces

The instruction files and custom agents you wrote in Module 2 (`.github/copilot-instructions.md`,
path-scoped `.github/instructions/*.instructions.md`, `AGENTS.md`, and `.github/agents/`) are read by
VS Code, the CLI, and the cloud agent, code review reads the instruction files too, and the portable
`.mcp.json` serves both VS Code's Copilot harness and the CLI. One pull request that improves those
files improves every surface that reads them.

The sharing isn't perfectly uniform, and it helps to know where the seams are. GitHub's support table
shows Copilot Chat on GitHub.com reading only the repository-wide file, some VS Code features (prompt
files and handoffs among them) work only in the Local harness, and the cloud agent's MCP servers are
configured in repository settings rather than in `.mcp.json`. And if portability across harnesses
matters more to you than across Copilot surfaces, `AGENTS.md` is the file that OpenCode and Kiro read
as well.

### Governance an enterprise can enforce

Administrators get controls that apply across surfaces: a single **Copilot in the cloud** policy for
the web experience, a Copilot CLI policy for the CLI and the app, an **MCP servers in Copilot** policy,
and MCP allowlists in an enterprise `managed-settings.json` that the Copilot app, the CLI, and VS Code
all enforce. Organizations can also require the CLI's local sandbox. Kiro's enterprise console has a
similar set (an approved model list, an MCP allowlist, and admin permission rules), though Kiro says
some of its admin settings, MCP configuration among them, don't yet apply to Kiro Web sessions.

---

## Where Copilot is constrained

### The cloud agent works only with GitHub-hosted repositories

GitHub's docs are direct about it: "Copilot only works with repositories hosted on GitHub." If your
code lives in Azure Repos, GitLab, or Bitbucket, the cloud agent and its issue-to-pull-request flow
aren't available to you, and rulesets or branch protection can block it even on GitHub unless it's
granted a bypass. Kiro Web, by contrast, supports GitLab repositories, and OpenCode is indifferent to
where your remote lives because it runs `git` locally.

### One repository per task, with a time cap on Actions sessions

How tight this is depends on where the session runs. A session on **GitHub Actions** can change only
the repository you started it in, and it has a maximum execution time of 59 minutes that "cannot be
extended or bypassed". Sessions started by assigning an issue still run on Actions, so the classic
flow from Module 3 carries both limits. The newer **cloud sandboxes**, the default for sessions you
start elsewhere, can span repositories in one organization, and GitHub's October launch post says they
have no one-hour limit on total running time; the docs don't state a sandbox limit, so check the
current page before you plan a long task. Either way, the agent works on one branch at a time and
opens one pull request per task.

The two environments also differ in what you can customize. Only Actions sessions honor
`copilot-setup-steps.yml`, self-hosted runners, and custom compute, and cloud sandboxes support none
of those, though they do honor firewall allowlists. For .NET teams there's one more wrinkle: the
Actions environment supports only Ubuntu x64 and Windows 64-bit runners (no macOS), Windows needs
larger or self-hosted runners, and the agent's firewall doesn't work on Windows or self-hosted runners.

### The model menu is set by GitHub

You choose from GitHub's list, and GitHub decides when a model joins or leaves it. Bring-your-own-key
works in VS Code, the CLI, and the Copilot app, but not in the cloud agent, and in VS Code it covers
chat and utility tasks only, while inline suggestions, semantic search, and embeddings still go
through GitHub. When a plan's AI Credits run out there's no automatic fallback to a cheaper model.
OpenCode is the opposite case, since the provider list is yours. Kiro sits closer to Copilot here,
with a curated list and no documented BYOK.

### The agent services are proprietary

The main open-source parts of Copilot are VS Code itself (`microsoft/vscode`, MIT), which has included the
Copilot Chat code since version 1.116, the Copilot SDK (`github/copilot-sdk`, MIT), and the GitHub MCP
server (`github/github-mcp-server`, MIT). The SDK is a set of client libraries, though, and by default
it drives the agent runtime inside the Copilot CLI, which is closed. The CLI ships under a proprietary
license that forbids modifying it or creating derivative works, and its public repository holds no
source. The Copilot app's repository has no license, and the cloud agent, code review, and the models
are hosted services. You can't self-host the agent services or audit their code. OpenCode's agent is
MIT from end to end, while Kiro is in much the same position as Copilot, with proprietary products and
a few Apache-2.0 and MIT-0 side projects.

### Costs run on two meters

Copilot bills model use in **AI Credits**, token-metered at each model's API rate since 2026-06-01,
and the cloud agent and code review also consume GitHub Actions compute from a single dollar-based
entitlement (cloud-sandbox billing starts in November 2026). A code review averages about $0.25 in
AI Credits at the Lite effort level and $1.50 at Balanced, plus its Actions minutes (a self-hosted
runner uses none). The new Copilot in the cloud experience requires a paid plan, so lab seats need
Pro, Business, or higher. None of this is unusual (Kiro bills in credits with
model multipliers, and OpenCode passes your provider's bill straight through), but it's two meters to
watch instead of one.

### It changes every week

VS Code and the CLI both ship weekly, and the product has changed shape several times recently: the
"coding agent" became the cloud agent, Edit mode went away, chat participants were deprecated, and
billing moved from premium requests to AI Credits. That pace brings features quickly, but it also means
button labels in screenshots age within weeks, so verify against the build you're actually running.

---

## Choosing for your team

None of the three is the right answer everywhere, and the deciding factors are mostly about your
environment rather than the agent loop:

- Copilot fits teams whose code is on GitHub and who want the issue-to-pull-request flow with built-in
  scanning and review, the same customizations across IDE, terminal, and web, and enterprise policy
  over all of it.
- OpenCode fits teams that need an open-source harness, any model provider including local ones, or
  freedom from a particular forge, and who are willing to own containment themselves, since it has no
  sandbox and no supported GitHub Action.
- Kiro fits teams drawn to spec-driven development, AWS-hosted models in US or EU regions, or GitLab
  support for cloud work, and who are comfortable with a proprietary product and a curated model list.

Whichever you choose, keeping your conventions in `AGENTS.md` leaves the door open to the others.

---

## Summary

- Copilot's strengths are one harness from VS Code to the terminal to GitHub.com, an issue-to-pull-
  request flow with CodeQL, secret scanning, dependency checks, and code review built in, a
  multi-vendor model picker, and customization files shared across surfaces.
- The cloud agent works only with GitHub-hosted repositories; Actions sessions (including issue
  assignment) are limited to one repository and 59 minutes, while cloud sandboxes can span one
  organization's repositories.
- GitHub sets the model menu; BYOK works in VS Code (for chat and utility tasks), the CLI, and the
  app, but not in the cloud agent.
- VS Code (with its built-in chat), the Copilot SDK client libraries, and the GitHub MCP server are
  open source; the CLI, the app, and the agent services are proprietary.
- Model use costs AI Credits and cloud work also costs Actions compute; weekly releases mean labels
  drift.
- OpenCode trades Copilot's integration for openness and provider freedom, and Kiro offers specs and
  AWS hosting under a similarly proprietary model.
