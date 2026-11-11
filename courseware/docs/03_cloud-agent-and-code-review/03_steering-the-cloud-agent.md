# Steering the Cloud Agent

When you give agent mode a task in VS Code, you can correct it as soon as it heads the wrong way. A cloud
session doesn't give you that chance, because by the time you look, the agent may have spent half an hour on
its own reading of your request. Steering it well comes down to what you put in front of it before it
starts and to the channel you use once it's running. In practice that means a well-written issue, the
follow-up loop on the pull request, and three kinds of context you can bring along: custom agents, Copilot
Spaces, and Copilot Memory.

---

## The issue is the prompt

When you assign an issue, Copilot takes its title, its body, and the comments already on it, plus anything
you type in the **Optional prompt** field when you assign it. That's the whole brief. It
ignores comments added to the issue after assignment, so a clarification posted there half an hour later
never reaches the agent.

An issue the agent can act on answers three questions a new teammate would ask. What does "done" look like,
in terms someone could check? Where in the code should the work go, and what already exists that it should
reuse? How do you prove it works? An issue that answers all three tends to come back as a pull request you
can merge, and one that answers none of them tends to come back as a reasonable guess.

---

## A vague issue and one it can act on

Here's the overdue-loans request from the library demo, written the way it often arrives:

```markdown
# Overdue loans

Staff want to see which loans are overdue. Can we add an endpoint for this?
```

Nothing in it is wrong, but the agent has to invent the path, the response shape, the sort order, what
"overdue" means, and whether fees are involved. Each of those guesses is a review comment waiting to happen.
The same request written for the agent looks like this:

```markdown
# Add GET /loans/overdue

Desk staff need a list of loans that are past due so they can chase returns.

## Acceptance criteria
- `GET /loans/overdue` returns 200 with a JSON array, empty when nothing is overdue.
- A loan is overdue when it hasn't been returned and its due date is before today.
- Each item has `loanId`, `isbn`, `memberId`, `dueOn`, `daysOverdue`, and `feeIfReturnedToday`.
- Most overdue first. Returned loans never appear.
- The new route must not break `GET /loans/{id}`.
- Add a line under `## [Unreleased]` in `CHANGELOG.md`.

## Where to look
- Put the query in `LoanService` (`src/Library.Domain/Lending/LoanService.cs`, or
  `lending/LoanService.java`) and the route next to the other loan endpoints
  (`src/Library.Api/Program.cs`, or `web/LibraryController.java`).
- Work out `feeIfReturnedToday` with the existing `LateFeeCalculator` (board policy LIB-12).
  Don't copy or change the fee rules.
- Get "today" from the injected clock (`TimeProvider` in .NET, `Clock` in Java), never the system time.

## How to test
- Domain tests that move the test clock (`FixedClock` in .NET, `MutableClock` in Java) past a due date.
- Run `dotnet test` (.NET) or `sh ./mvnw -B verify` (Java). Every test must pass.

## Out of scope
- No changes to borrowing, returns, or the lending rules. No new packages.
```

Every section of the second version has a job: the acceptance criteria are written so a test can check
each one, and they settle the questions the vague version left open. The file pointers stop the
agent from searching the whole repository and, more important, tell it which existing pieces to reuse.
Without the line about `LateFeeCalculator`, a perfectly plausible pull request could reimplement the fee
rules in a second place, and the two copies would drift apart the next time the board changes LIB-12. The
clock note matters for the same reason: the existing tests control time through `FixedClock` and
`MutableClock`, and code that reads the system clock can't be tested that way. The build commands are the
Linux forms because the agent's runner is Ubuntu. The out-of-scope list is the cheapest guardrail of all,
since it costs one line and heads off a sprawling diff.

The issue is long for an endpoint this small, and that's fine. You write it once, a teammate can review it
before you assign it, and it doubles as the description a reviewer reads later.

---

## Iterating on the pull request

Once the session is under way, the pull request becomes the conversation. Mention **`@copilot`** in a pull
request comment and Copilot picks the request up: it reacts with an eyes emoji, a new "started work" event
appears on the timeline, and it pushes its changes to the same branch unless you ask for a new pull
request. It keeps context across sessions on the same pull request, so you don't need to repeat the
original brief.

```text
@copilot Please add an API-level test for GET /loans/overdue in Library.Api.Tests that checks an empty
array comes back when no loan is past due.
```

A few rules shape this loop. Copilot responds only to people with write access to the repository, and it
stops responding once the pull request is merged or closed. The mention works on any pull request,
including ones a person opened, so you can ask Copilot to finish a colleague's half-done branch. Review
comments have their own route, **Fix with Copilot** and **Add to batch**, which chapter 4 covers alongside
Copilot code review.

When CI fails or the branch picks up merge conflicts, there are two more ways to hand the problem back. A
failing Actions job offers **Fix with Copilot**, and since 2026-10-28 the merge box on paid plans has
**Agent Merge**: choose **Watch and fix**, pick failing workflows, merge conflicts, or both, and Copilot
fixes them in a cloud environment. It combines with auto-merge, and it can be switched on by default from
your Copilot settings.

---

## Custom agents from the repository

The custom agents you wrote in Module 2 work on GitHub too, because any `.github/agents/NAME.agent.md` file
in the repository shows up in the agent dropdown when you assign an issue to Copilot and in the agent
dropdown on the Agents tab. Picking one gives the session that agent's instructions, tool list, and model
instead of the defaults. The course's `.github/agents/test-writer.agent.md` suits a follow-up issue that
asks only for more tests, where you want a narrow change that leaves production code alone.

A few frontmatter details decide how an agent behaves on GitHub:

| Property | What the cloud agent does with it |
|---|---|
| `target` | `vscode` or `github-copilot`; when it's unset, the agent is available in both |
| `tools` | Limits the tools the agent can call; unset or `["*"]` means all of them |
| `model` | Overrides the default model; when it's unset, the agent inherits it |
| `handoffs`, `argument-hint` | IDE-only; the cloud agent ignores them |

The `web` tool alias isn't used by the cloud agent, and the prompt body of an agent file can be up to 30,000
characters. If an agent should be available across every repository in your organization, an
organization owner can put it in a top-level `agents` folder in the organization's `.github` or `.github-private` repository
instead.

Instruction files steer the agent the same way they steer agent mode. If one of your path-specific files is
meant only for code review, mark it `excludeAgent: "cloud-agent"` and the cloud agent will leave it out.

---

## Copilot Spaces

A Copilot Space is a curated collection of context: repositories, code, pull requests, issues, free text,
images, and uploaded files. Sources that come from GitHub stay current on their own. Spaces are meant for
the kind of knowledge that lives outside any single file, such as the library board's policy documents, the
reasoning behind the LIB-12 fee rules, or the notes from a design discussion.

You use a Space from Copilot Chat on GitHub.com, or from an IDE through the GitHub MCP server. GitHub also
lists Spaces among the customizations for Copilot in the cloud, but assigning an issue offers no place to
attach one, so for an issue-assigned task, copy what the agent needs into the issue itself.
Organization Spaces can be shared with admin, editor, or viewer roles, and personal Spaces can be public,
shared with specific people, or private. Any Copilot license, Free included, can use them, and questions
asked against a Space consume AI Credits.

---

## Copilot Memory

Copilot Memory lets Copilot remember facts about your repositories and your personal coding preferences
from one session to the next, and it's generally available on paid plans since 2026-10-28. The two halves
behave differently. Repository facts are shared with the repository's collaborators, and creating one takes
write access. Personal preferences follow you from repository to repository, but Copilot code review never
applies them.

The cloud agent is one of many surfaces that use Memory, alongside the Copilot app, the CLI, code review,
GitHub Mobile, and Slack and Teams. VS Code supports it too, though its memory setting is off by default.
Before Copilot relies on a repository fact, it checks the fact's citations against the current branch, so
something that was true of last month's code doesn't get applied blindly. That check is a judgment call,
not a guarantee, so a rule that must always hold still belongs in your instructions. Memories expire after
**90 days** unless they're reinforced, and organizations can set the period for repository facts anywhere
from 7 to 180 days.

Repository facts are allowed by default on every plan unless a setting restricts them. Personal preferences
are on by default for Pro, Pro+, and Max, and you can opt out. On Business and Enterprise, which is what a
class sandbox usually runs on, they stay off until an owner enables the policy. You can review and delete
your own memories at `github.com/settings/copilot/memory`.

---

## Summary

- Copilot reads the issue's title, body, and existing comments, plus the **Optional prompt**. It ignores
  issue comments added after assignment.
- A good issue states checkable acceptance criteria, points at the files and existing code to reuse, says
  how to test, and lists what's out of scope.
- After assignment, steer with **`@copilot`** comments on the pull request; Copilot pushes to the same
  branch and keeps context. **Fix with Copilot** and **Agent Merge** hand failing CI back to it.
- Custom agents in `.github/agents` appear in the agent dropdown when you assign an issue and on the
  Agents tab. `handoffs` and `argument-hint` are IDE-only.
- **Copilot Spaces** bundle context that lives outside the code. For an issue-assigned task, put what the
  agent needs in the issue.
- **Copilot Memory** keeps repository facts and personal preferences and expires memories after 90 days by
  default. Personal preferences stay off on Business and Enterprise until the policy is enabled.
