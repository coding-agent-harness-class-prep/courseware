# Welcome to GitHub Copilot as a Coding-Agent Harness

A hands-on overview of agentic development in VS Code, the GitHub Copilot CLI, and GitHub.com for .NET
and Java teams.

GitHub Copilot is a coding-agent harness: the same agent loop, tools, context files, and approval model
run inside VS Code, in a terminal through the GitHub Copilot CLI, and as a cloud agent on GitHub.com
that takes an issue and returns a pull request. In this session you work with all three on a real
codebase, in .NET or Java, and finish with a comparison of Copilot, OpenCode, and Kiro.

## Outline Summary

### Module 1: The Copilot Harness and Chat in VS Code

- Model versus harness
- The capability ladder
- Chat that knows the project
- Choosing a model
- Activity: explain unfamiliar code, then generate and run a unit test

### Module 2: Agent Mode in VS Code with Instructions, Custom Agents, and MCP

- Agent mode, tools, and approvals
- Repository instructions and `AGENTS.md`
- Custom agents
- MCP servers
- Activity: a validation rule in agent mode, with and without repository instructions

### Module 3: GitHub.com, the Cloud Agent and Code Review

- The Copilot cloud agent and the Agents panel
- Inside a cloud run
- Steering the cloud agent
- Copilot code review
- Pull request summaries, Chat on GitHub.com, and other agents
- Activity: turn an issue into a pull request with agent mode and review it with Copilot

### Module 4: The GitHub Copilot CLI in the Terminal

- What the Copilot CLI is
- Interactive and programmatic use
- Permissions and the sandbox
- GitHub integration and MCP
- Reusing customizations, second opinions, and handoffs
- Activity: fix a reported bug from the terminal, open a pull request, and hand a follow-up to the cloud
  agent

### Conclusion

- Copilot, OpenCode, and Kiro side by side
- Where Copilot stands out and where it's constrained

## Courseware

NOTE: The course documents are for your reference. The session is taught with live demos and
hands-on work in the product, and the documents are used lightly in class.

- [Start here: make your practice repo](./courseware/setup/student-quick-start.md)
- [Outline](./courseware/outline/pdf/GitHubCopilotAsACodingAgentHarness_Outline.pdf)
- [Documentation](./courseware/docs/README.md)
- [Activities](./courseware/activities/README.md)
- [Demos](./courseware/demos/README.md)
- [Slides](./courseware/slides/pdf/GitHub-Copilot-as-a-Coding-Agent-Harness-All-Slides.pdf)

## Links

- [GitHub Copilot documentation](https://docs.github.com/en/copilot)
- [GitHub Copilot in VS Code](https://code.visualstudio.com/docs/agents/overview)
- [GitHub Copilot CLI](https://github.com/github/copilot-cli)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [GitHub Changelog: Copilot](https://github.blog/changelog/label/copilot/)

## License

The programming code authored by the instructor in this repository is made available under the [MIT license](LICENSE). However, please note that the course documents, exercise instructions, and course outline are provided exclusively for students enrolled in this course and aren't to be shared, transferred, or sold to others.

<br><br>
Course delivered by Xebia.
