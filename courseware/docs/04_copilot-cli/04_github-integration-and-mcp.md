# GitHub Integration and MCP Servers

A coding agent that can't see your issue tracker has to be told everything twice: once in the issue,
and again in the prompt. The Copilot CLI ships with GitHub built in, so the issue that describes a
bug, the pull request you're iterating on, and the repository around them are a `#` away. The
mechanism that provides those tools is the **Model Context Protocol (MCP)**, the same one you used in
Module 2, and it's also how you add tools from your own systems.

---

## The built-in GitHub MCP server

As a reminder, MCP is an open protocol in which a *server* exposes tools (search issues, read a pull
request, query an inventory system) and the agent's harness acts as the *client* that calls them.
Each call is a tool call like any other, so it goes through the approval flow from chapter 3.

The CLI starts a built-in GitHub MCP server, `github-mcp-server`, so GitHub access needs no
configuration. Out of the box it's read-only and exposes a *default CLI subset* of the server's tools
(reading files, searching code, and the like), and for jobs that overlap with `gh` the agent tends to
reach for the GitHub CLI instead. The server is organized into toolsets such as `issues`,
`pull_requests`, and `copilot` (which holds `assign_copilot_to_issue` and `request_copilot_review`).
Name a toolset or a tool at launch and the CLI enables it, write tools included:

```powershell
copilot --add-github-mcp-toolset pull_requests # repeatable; "all" adds every toolset
copilot --add-github-mcp-tool request_copilot_review   # repeatable; "*" adds every tool
copilot --enable-all-github-mcp-tools          # everything; overrides the two flags above
```

Going the other way, `--disable-mcp-server <name>` switches off one server for a run and
`--disable-builtin-mcps` switches off the built-in servers, which is what the CI illustration in
chapter 2 does. Inside a session, `/mcp` manages MCP servers and `/env` lists the ones that loaded.

---

## Issues and pull requests in a prompt

`#NUMBER` pulls an issue or pull request into the conversation. That's the cleanest way to start work
on a bug that someone has already written up, because the agent reads the reproduction steps and the
expected behavior in the reporter's own words:

```text
Read #42. Run the tests to reproduce the failure it describes, then explain the cause.
Don't change any code yet.
```

`/pr` shows the status of the current branch's pull request, and its subcommands create one or work
through review comments, conflicts, and failing checks (`/pr fix`). `/research` runs a deeper
investigation using GitHub search and web sources when the question is bigger than one repository.

### Opening a pull request without leaving the terminal

There are two routes. `/pr create` pushes the current branch and opens (or updates) its pull request,
following the repository's pull request template if it has one. Or you just ask, and the agent breaks
the job into the tool calls it needs: create a branch, commit, push, and open the pull request.

```text
Create a branch named fix/issue-42, commit the fix with a message that references #42,
push the branch, and open a pull request against main whose description says "Fixes #42".
```

Because the built-in GitHub tools are read-only by default, that last step normally runs as
`gh pr create` in the shell, so the GitHub CLI needs to be installed and signed in (`gh auth status`
tells you). Start the CLI with `--add-github-mcp-toolset pull_requests` if you'd rather the agent use
the GitHub server's own pull request tools.

In manual mode each of those steps arrives as its own approval prompt unless you've already allowed it,
and the push and the pull request are the two worth reading carefully, because they're the first moments
your work leaves your machine. Once the pull request exists you can ask Copilot code review to look at
it, either with `gh pr edit 42 --add-reviewer '@copilot'` or by asking the agent, which can call
`request_copilot_review` once the `copilot` toolset is enabled.

---

## Adding your own MCP servers

The CLI reads MCP configuration from several places and combines them:

| Scope | Where | Notes |
|---|---|---|
| User | `~/.copilot/mcp-config.json` | Yours, in every repository; `copilot mcp add` writes here |
| Workspace | `.mcp.json` in any folder from the working directory up to the repo root, or `.github/mcp.json` | Committed with the repo; loads only in a trusted folder. A folder's `.mcp.json` replaces its `.github/mcp.json` outright (they aren't merged); between folders, on a name clash the closer file wins |
| Plugin | Installed plugins that bring MCP servers | Managed with `copilot plugin` |
| One run | `--additional-mcp-config <json or @file>` | Adds servers for this session only |

Notice what's missing from that table: the CLI doesn't read `.vscode/mcp.json`, which uses a different
top-level key (`servers`). The portable format is `mcpServers`, and it's the one the VS Code Copilot
harness reads from a workspace `.mcp.json` too. That's why the CLI loads the `.mcp.json` you committed
in Module 2 without edits. Its `github` entry sits beside the built-in `github-mcp-server`, so
`copilot mcp list` shows both; if the CLI can't sign in to the committed copy, the built-in server
still covers everything this module does with GitHub.

### `copilot mcp add`

The quickest way to add a personal server is from the command line. Everything after `--` is the
command that starts a local (stdio) server, and `--transport http` adds a remote one by URL. The
server names and packages below are placeholders for your own internal systems:

```powershell
# A local (stdio) server
copilot mcp add catalog -- npx -y @contoso/catalog-mcp

# A remote (HTTP) server, exposing only two of its tools
copilot mcp add --transport http tickets https://mcp.contoso.example/ --tools "search_tickets,get_ticket"

copilot mcp list             # everything configured, from every source
copilot mcp get catalog      # one server's details
copilot mcp disable catalog  # keep the config, stop loading it
```

`--env KEY=VALUE` and `--header "Name: value"` can be repeated for servers that need settings or
authentication, and `--tools` takes `"*"` for all tools, a comma-separated list, or `""` for none.
Allowlisting tools here is the same idea as the `tools` list in the cloud agent's MCP configuration
from Module 3, and it's the simplest way to keep a server's write tools out of the agent's reach.

### A workspace `.mcp.json`

For a server the whole team should get, commit it to the repository instead. The shape matches the
user file, and `${NAME}` (or `${NAME:-default}`) pulls a value from the environment so nobody commits
a secret:

```json
{
  "mcpServers": {
    "catalog": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@contoso/catalog-mcp"],
      "env": { "CATALOG_URL": "${CATALOG_URL}" },
      "tools": ["*"]
    }
  }
}
```

`stdio` and `local` mean the same thing to the CLI, but `stdio` is the standard MCP name, so other
clients read it too. A remote server uses `"type": "http"` with a `url` and optional `headers` in
place of `command` and `args`.

### Approving and containing MCP tools

MCP tools use the same permission patterns as everything else. The server name stands for all of its
tools and `server(tool)` for one, so a team might pre-approve a server and still refuse its one
destructive tool:

```powershell
copilot --allow-tool='catalog' --deny-tool='catalog(delete_item)'
```

When the local sandbox is on, you can choose to start local (stdio) MCP servers inside it as well, so
they inherit the same filesystem and network limits. Remote (HTTP) servers are never sandboxed.

---

## When a server won't load

Two things outside your machine can stop an MCP server, and both are worth checking before you debug
the server itself. Organizations can switch MCP off entirely with the **MCP servers in Copilot**
policy, and enterprises can publish an allowlist or denylist (`allowedMcpServers` and
`deniedMcpServers` in an enterprise `managed-settings.json`) that the Copilot app, the CLI, and VS Code
all enforce. On your side, remember that a workspace `.mcp.json` loads only after you've trusted the
folder.

It's also worth knowing that the cloud agent keeps its own MCP configuration in the repository's
settings on GitHub (Module 3). A server that works in your terminal isn't automatically available to
a task you delegate, so check there before you hand off work that depends on one.

---

## Summary

- The built-in `github-mcp-server` starts with a read-only subset of GitHub tools; widen it with
  `--add-github-mcp-toolset`, `--add-github-mcp-tool`, or `--enable-all-github-mcp-tools`.
- `#NUMBER` brings an issue or pull request into the prompt. `/pr create` opens a pull request for the
  current branch, or you ask for one and approve each step, which usually ends in `gh pr create`.
- Personal servers live in `~/.copilot/mcp-config.json` (`copilot mcp add` writes there); team servers
  go in a workspace `.mcp.json` or `.github/mcp.json` using the portable `mcpServers` format.
- The CLI doesn't read `.vscode/mcp.json`; the `.mcp.json` from Module 2 is the file that both the CLI
  and the VS Code Copilot harness read.
- MCP tools obey the same allow and deny patterns (`server`, `server(tool)`), and org policy or an
  enterprise allowlist can block a server before it ever starts.
