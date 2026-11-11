# Pull Request Summaries, Chat, and Other Agents

Not everything Copilot does on GitHub.com takes the shape of a long-running task. Two of its handiest
features finish in seconds: a summary that drafts a pull request description for you, and a chat that
answers questions about a repository from whatever page you're on. The last part of the module goes the
other way, toward more autonomy rather than less, and looks at running the Claude and Codex coding agents
from the same Agents panel as the Copilot cloud agent.

---

## Pull request summaries

A good pull request description saves every reviewer a few minutes, and since it's also the part people
most often skip, it helps that Copilot can draft one from the diff. In the toolbar of the pull request
description field (or of a comment), select the Copilot icon, which screen readers announce as **Copilot
actions**, and choose **Summary**. Read what it wrote, edit anything that's off, and then create the pull
request or post the comment as usual.

Three things to know before you rely on it:

- The summary ignores any text already in the box, so start from a blank description.
- It doesn't update itself when you push more commits. Generate a new one if the pull request changes a lot.
- It isn't available on Copilot Free.

Summaries are most useful on pull requests a person opens, but they also help at the end of a cloud-agent
pull request. After a round of review fixes, a fresh summary in a comment gives the final reviewer one place
to read what the branch does now. Keep in mind that a summary describes what changed, not whether the change
is right. It's a map for the review, and the review still has to happen.

---

## Copilot Chat on GitHub.com

Chat on GitHub.com lives at **`https://github.com/copilot`**, and it's available from any page on GitHub.
Open it while you're looking at a repository, an issue, or a pull request, and that becomes the context for
your question. It suits the questions that come up while you're reading code in the browser and don't
justify cloning the repository:

```text
In this repository, how is the late fee worked out for a senior member, and which tests cover it?
```

```text
Summarize what pull request #17 changes and list every file that touches fee calculation.
```

A model dropdown lets you choose the model, and you can regenerate an answer with a different one to
compare. The plus icon attaches images or PDFs when the model accepts them, which is handy for a
screenshot of an error or a scanned policy document.

With Copilot in the cloud, a question and a piece of agent work share one session, so you can ask how
something works and then ask Copilot to change it without starting over. Nothing turns into a pull
request until you ask for one. That's the paid-plan experience; Copilot Free users keep the older Chat. To
hand over a task in one step, type `/task` with a description and select **Start task**:

```text
/task Add GET /books/{isbn} that returns one book or 404, with tests and a CHANGELOG line.
```

GitHub.com and GitHub Mobile also support `/rubber-duck` and `/context`, two commands you'll meet again in
the Copilot CLI in Module 4.

### What Chat on GitHub.com reads

Chat on GitHub.com reads a different set of instructions from the agents: the repository-wide
`.github/copilot-instructions.md`, your personal instructions, and organization instructions (on Business
and Enterprise plans). It doesn't read path-specific instruction files or `AGENTS.md`. When instructions
overlap, personal ones win, then the repository's, then the organization's. You can also bring a Copilot
Space into the conversation when the answer depends on knowledge that isn't in the code.

---

## Other coding agents in the Agents panel

Two third-party coding agents also run from the Agents panel, alongside Copilot's own, and both are in
public preview:

| Agent | Built on | Models it offers (examples) |
|---|---|---|
| Anthropic Claude coding agent | Claude Agent SDK | Auto, Claude Sonnet 4.6, Sonnet 5, Opus 4.8, Opus 5, Fable 5.1 |
| OpenAI Codex coding agent | Codex SDK | Auto, GPT-5.3-Codex, GPT-5.4 nano |

They're available on the Pro, Pro+, Max, Business, and Enterprise plans, and a policy has to allow them
before anyone can use them. The switches are named **Allow Claude coding agent** and **Allow Codex coding
agent**, and they live in your account settings, in organization policies, or in the enterprise AI
controls under **Agents**. Turning one on installs a GitHub App (`anthropic code agent` or `openai code
agent`). These policies cover the agents on GitHub only; they don't govern the Claude and Codex harnesses
running locally in VS Code.

Once an agent is enabled, you can reach it in the same places you reach Copilot:

- the agent picker under the prompt box on the Agents tab
- the agent choice when you assign an issue
- an `@AGENT_NAME` mention in a pull request comment
- GitHub Mobile and VS Code

Third-party agents share the Copilot cloud agent's economics and safety net. They consume GitHub Actions
minutes and AI Credits, and their changes get the same security checks that chapter 2 described: CodeQL,
secret scanning, and the dependency check. A practical use is a second opinion on a design: start the same
well-written issue as a task for two different agents and compare the pull requests they return.

---

## Summary

- **Pull request summaries:** Copilot icon (**Copilot actions**) → **Summary** in the description or
  comment toolbar. Start from a blank box, regenerate after big pushes, and remember it isn't on Copilot
  Free.
- **Chat on GitHub.com** at `github.com/copilot` works from any page, with the repository, issue, or pull
  request as context. It has a model dropdown and attachments.
- On paid plans a question can turn into agent work in the same session; `/task` hands over a task in
  one step.
- Chat on GitHub.com reads repository-wide, personal, and organization instructions, but not path-specific
  files or `AGENTS.md`.
- The **Claude** and **Codex** coding agents run from the Agents panel in public preview once a policy
  allows them. They use Actions minutes and AI Credits and get the same security checks as Copilot.
