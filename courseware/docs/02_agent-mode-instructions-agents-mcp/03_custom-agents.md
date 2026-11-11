# Custom Agents

Instruction files describe the repository to every session, while a *custom agent* is something
narrower: a named specialist with its own prompt and a set of tools chosen for its job. A read-only
reviewer that checks changes against the library's lending policies is a good example, and so is a
test writer that's allowed to touch `tests/` but never `src/`. You define each one once, in a Markdown
file in the repository, and pick it by name in VS Code, in the Copilot CLI, and on GitHub.com.

---

## Where agent files live

A repository's custom agents live in `.github/agents/`, one file per agent, named `NAME.agent.md`. The
file name may contain only letters, digits, `.`, `-`, and `_`. The two agents used in this course are:

```text
.github/agents/policy-guard.agent.md    # instructor demo: read-only policy reviewer (library app)
.github/agents/test-writer.agent.md     # Activity 02: writes tests, never production code (orders app)
```

Custom agents used to be called *custom chat modes*. If you have old `.chatmode.md` files, rename them
to `.agent.md` to migrate.

---

## Anatomy of an agent file

An agent file is YAML front matter followed by a Markdown body. The front matter configures the agent,
and the body is its prompt: the instructions it follows every time it runs. Here's the demo's reviewer
(the Java version differs only in saying `BigDecimal` and `Clock`):

```markdown
---
name: policy-guard
description: Read-only reviewer that checks a change against the library's lending and fee policies.
tools: ["read", "search"]
---

You review changes to the Library lending service against its business policies. You can read and
search the repository, but you can't edit files or run commands — say so if you're asked to.

When asked to review a change or a branch:

1. Find the rules it touches: loan limits and copy availability in `LoanPolicy`, due dates in
   `DueDateCalculator` and `LibraryCalendar`, and late fees in `LateFeeCalculator` (board policy LIB-12).
2. Check the conventions in `.github/copilot-instructions.md`: new rules report a `PolicyViolation`
   with a new, never-reused `PolicyCodes` constant; limits are named constants; money is `decimal`;
   dates come from the injected `TimeProvider`.
3. Check there's a test for each side of every new limit and a `CHANGELOG.md` entry.

Reply with a short list of findings, most serious first, each naming the file and line. If you find
nothing, say what you checked.
```

The `tools` line is what makes it a reviewer rather than a second pair of hands. With only `read` and
`search`, it can't edit a file or run a command no matter what it's asked, because the harness never
offers it those tools.

---

## Front matter fields

| Field | Required | What it does |
|---|---|---|
| `description` | Yes | What the agent is for, in one sentence |
| `name` | No | The agent's name |
| `tools` | No | Which tools it may use; unset or `["*"]` means all, `[]` means none |
| `model` | No | A specific model; otherwise it inherits the default |
| `target` | No | `vscode` or `github-copilot`; unset means both |
| `disable-model-invocation` | No | Default `false`; controls whether Copilot may invoke the agent by itself |
| `user-invocable` | No | Default `true`; controls whether people can pick the agent |

The prompt body can be up to 30,000 characters. A few older or surface-specific fields are worth
recognizing: `infer` is retired (use the two invocation fields above instead), `handoffs` and
`argument-hint` are IDE-only and ignored by the cloud agent, and `mcp-servers` and `metadata` aren't
used by VS Code or other IDE custom agents.

### Tool aliases

The `tools` list uses short aliases so the same file works on every surface:

| Alias | Equivalent names and notes | Gives the agent |
|---|---|---|
| `read` | Maps to `view` | Reading files |
| `edit` | | Editing and creating files |
| `search` | | Searching the codebase |
| `execute` | `shell`, `Bash`, `powershell` | Running commands |
| `agent` | `custom-agent`, `Task` | Calling other agents |
| `web` | Not used by the cloud agent | Fetching web content |
| `todo` | VS Code only | A task list |

MCP tools are named `server/tool`, so `github/*` grants every tool from an MCP server named `github`.
The activity's `test-writer` agent uses `tools: ["read", "search", "edit", "execute"]`, because it has
to create test files and run the suite; its prompt body is what keeps it out of production code.

---

## Picking a custom agent on each surface

The same file in `.github/agents/` shows up in three places:

| Surface | How you pick it |
|---|---|
| VS Code | Set **Session Target** to the harness, then choose the agent from the **Agent** dropdown |
| Copilot CLI | `/agent policy-guard` in a session, `--agent` on the command line, or name the agent in your prompt |
| GitHub.com | The agent dropdown in the agents panel or tab, or when you assign an issue to Copilot |

From the CLI, a one-off run looks like this:

```powershell
copilot --agent=policy-guard --prompt "Review the changes on this branch against the lending policies."
```

Non-interactive runs also need their tool permissions settled up front; Module 4 covers that. On
GitHub.com, picking a custom agent when you assign an issue means the cloud agent works the issue
using that agent's prompt and tools, which Module 3 picks up.

---

## Sharing agents beyond one repository

Agents don't have to live in each repository:

| Level | Location |
|---|---|
| Repository | `.github/agents/NAME.agent.md` |
| Organization | `agents/NAME.agent.md` in the organization's `.github` or `.github-private` repository |
| Enterprise | `agents/` in the `.github-private` repository of an organization chosen in enterprise settings |
| User | `~/.copilot/agents`, read by the CLI and VS Code's Copilot harness |

When the same agent exists at several levels, the closest level wins: repository over organization
over enterprise, and in the CLI a user agent beats all three. Agents are matched by file name without
the `.md` or `.agent.md` extension, so `policy-guard.agent.md` in a repository replaces an
organization's `policy-guard.md`.

---

## Agents, instructions, and skills

It's easy to blur these together, so here's the division of labor:

| Use | When the guidance is… |
|---|---|
| Repository instructions | True for every task in the repository: layout, conventions, how to run tests |
| A custom agent | A role with its own workflow and a deliberately limited set of tools |
| An agent skill (a folder with a `SKILL.md`, under `.github/skills/`) | A reusable procedure for one kind of task, packaged so several surfaces can use it |

Rather than repeating the repository's conventions in an agent's prompt, point at the instruction file,
as `policy-guard` does with `.github/copilot-instructions.md`. That keeps one place to change them and
leaves the prompt free for the agent's actual job.

---

## Summary

- Custom agents are Markdown files at `.github/agents/NAME.agent.md`: YAML front matter plus a prompt
  body of up to 30,000 characters.
- `description` is required; `tools`, `model`, `target`, `disable-model-invocation`, and
  `user-invocable` are optional, and `infer` is retired.
- Tool aliases (`read`, `edit`, `search`, `execute`, `agent`, `web`, `todo`) and `server/tool` names for
  MCP tools control exactly what the agent can do.
- Pick an agent from the **Agent** dropdown in VS Code, with `/agent` or `--agent` in the CLI, or from
  the agent dropdown on GitHub.com.
- Organization and enterprise agents live in `.github` or `.github-private` repositories, and the
  closest level wins when names collide.
