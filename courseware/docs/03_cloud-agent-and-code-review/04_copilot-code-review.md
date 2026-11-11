# Copilot Code Review

A pull request from the cloud agent still needs a reviewer, and Copilot can be one of them. Copilot code
review reads the changes in a pull request, gathers context from the rest of the project, and leaves review
comments, many with a suggested fix attached. It works on any pull request, whoever wrote it, and in this
module you'll aim it at the one the cloud agent hands back.

---

## What the reviewer does

Copilot code review is agentic: besides reading the diff, it gathers context from across the project,
calls tools, and can use MCP servers. Those agentic steps run on GitHub Actions, on standard GitHub-hosted
runners unless you set up larger or self-hosted ones, and if no runner is available you still get a
review, just without the extra context. The GitHub MCP server and the Playwright MCP server are on by
default, the setting **Allow Copilot to use MCP tools when reviewing pull requests** is on by default, and
it picks up skills from `.github/skills`.

You can ask for a review on GitHub.com, from the GitHub CLI, on GitHub Mobile, and from VS Code, Visual
Studio, Xcode, JetBrains IDEs, and Azure DevOps (in preview). The Copilot Free plan doesn't include code
review on pull requests. Business and Enterprise organizations can turn it on for members who don't have
a Copilot license, though those members can't use it in their IDEs.

---

## Requesting a review

On a pull request, open **Reviewers** and select **Request** next to **Copilot**. A review usually finishes
in under 30 seconds. From a terminal, the GitHub CLI adds Copilot the same way it adds a person:

```powershell
gh pr edit 17 --add-reviewer '@copilot'
```

```bash
gh pr edit 17 --add-reviewer @copilot
```

The quotes in the PowerShell version matter. PowerShell reads an unquoted `@copilot` as splatting a
variable named `$copilot`, which doesn't exist, so `gh` never sees the reviewer's name.
You can also add Copilot when you create the pull request with `gh pr create --reviewer @copilot` (quoted
the same way in PowerShell), or through the REST API, where the reviewer's name is
`copilot-pull-request-reviewer[bot]`.

Pushing new commits doesn't trigger another review by itself. To have Copilot look again, re-request it from
the **Reviewers** menu. Be aware that a re-review may repeat comments you already resolved.

### Automatic reviews

If you'd rather not remember to ask, set Copilot up to review automatically. The basic option reviews each
pull request when it's created, or when a draft becomes an open pull request. Two more options extend
that: **Review new pushes** reviews again after each push, and **Review draft pull requests** reviews
drafts too. Repository and organization admins configure this through rulesets, and since 2026-09-23
anyone on a paid plan can also turn it on for their own pull requests from the code review page of their
personal Copilot settings.

Reviews come at more than one depth. **Balanced** is the default, **Lite** is quicker and cheaper, and
**Max**, in public preview, is the most thorough. You can pick a level when you request a review, and you,
the repository, or the organization can set a different default.

---

## What a review gives you

By default Copilot leaves a **Comment** review. It doesn't approve or request changes, so it doesn't count
toward the approvals your branch rules require. An admin can change that: Copilot approvals, generally
available since 2026-10-28, are off until someone turns them on in repository, organization, or enterprise
settings, and a repository can restrict which file paths Copilot is allowed to approve. A new push
dismisses Copilot's approval. Every review includes an approval assessment either way.

Treat its comments the way you'd treat comments from a sharp colleague who joined last week. Most are worth
acting on, some miss context you have, and all of them are suggestions rather than verdicts.

---

## Working through its comments

Each comment can be handled in a few ways, and you'll usually mix them on one pull request:

- **Apply a suggested change.** Many comments come with a suggestion you can commit in a couple of clicks.
- **Hand it to the cloud agent.** **Fix with Copilot** on a comment passes it to the cloud agent, which
  fixes it on the same pull request or opens a new one. Handing review suggestions to the cloud agent is a
  public preview feature.
- **Batch several together.** **Add to batch** collects comments, then **Fix and commit** or **Fix and open
  pull request** sends them to Copilot as one piece of work.
- **Ask for something different.** Mention `@copilot` in a comment that describes the change you want,
  and the cloud agent picks it up.
- **Decline it.** Reply with your reasoning and resolve the thread. The reply is for the next person who
  reads the thread; the reviewer doesn't see replies.

When the fixes are in, re-request Copilot from **Reviewers** to confirm nothing new turned up.

---

## Custom review instructions

Copilot code review reads the same instruction files as the other agents, plus one of its own. On GitHub.com
it uses:

- `.github/copilot-instructions.md`
- path-specific `.github/instructions/**/*.instructions.md` files, except those marked
  `excludeAgent: "cloud-agent"`
- `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`
- **`REVIEW.md`**

Copilot reads these files from the pull request's **head branch**, the branch with your changes, not from the
base branch. One consequence is that a pull request that edits `REVIEW.md` is reviewed under its own edited
rules, so changes to instruction files deserve a careful human look. Repository admins can switch all of
this off with **Use custom instructions when reviewing pull requests** under Settings → Copilot → Code
review.

### A REVIEW.md for the library app

The library service has a few rules that a generic reviewer wouldn't know to enforce. A short `REVIEW.md`
like this one spells them out:

```markdown
# Review guidance: library lending service

Flag each of these in review and point to the line.

## Money
- Fees and fines are `decimal` in C# and `BigDecimal` in Java. Flag any `double`, `float`,
  or floating-point literal in fee or fine arithmetic.
- Late-fee rules (board policy LIB-12) live only in `LateFeeCalculator`. Flag fee logic anywhere else.

## Policy codes
- `LIB001` and `LIB002` are part of the public API. Flag any change to an existing code's value
  or meaning. A new rule gets the next unused code.

## Changelog
- A change to behavior or to an endpoint needs a line under `## [Unreleased]` in `CHANGELOG.md`.
  Flag the pull request if it's missing.

## Tests
- New behavior comes with tests. Tests that depend on the date use the test clock, never the system time.
```

Each rule is concrete enough to check, names the files it applies to, and says what to flag. "Write clean
code" gives a reviewer nothing to act on, while "flag `double` in fee arithmetic" does.

### Review-only path-specific instructions

When guidance applies to one part of the code and only to review, a path-specific file with `excludeAgent`
keeps it away from the cloud agent:

```markdown
---
applyTo: "src/Library.Domain/Fees/**,src/main/java/com/example/library/fees/**"
excludeAgent: "cloud-agent"
---
When reviewing fee code, check each change against board policy LIB-12: the grace period, the
senior fee-free days, the student rate, and the cap per loan. Ask for a test for any rule that changes.
```

The other value, `excludeAgent: "code-review"`, does the opposite and keeps a file away from the reviewer.
Without either, both agents use the file.

### How long the files can be

GitHub's current guidance is to keep any single instruction file to about 1,000 lines at most. Older posts
quote a 4,000-character limit that the current docs no longer mention. A review file like the one above is
nowhere near either.

Reviews in the editor may read less. GitHub's support table lists only `.github/copilot-instructions.md`
for code review in VS Code, so a rule that must also hold before you push belongs in that file as well.

---

## What it costs

Each review consumes AI Credits, and GitHub's approximate averages are about $0.25 for a Lite review, $1.50
for Balanced, and $10 for Max. Because the reviewer runs on GitHub Actions, it also uses Actions minutes,
unless it runs on self-hosted runners, which don't. Automatic reviews on every push add up, so decide per
repository whether **Review new pushes** earns its cost.

---

## Reviewing before you push

You don't have to wait for a pull request. In VS Code, hover over **CHANGES** in the Source Control view and
choose **Copilot Code Review - Uncommitted Changes**; the comments appear inline and in the Problems panel.
Visual Studio 17.14 and later has **Review changes with Copilot** in Git Changes, JetBrains IDEs have
**Copilot: Review Code Changes** in the Commit window, and the Copilot CLI has `/review`, which Module 4
covers.

---

## Summary

- Request a review from **Reviewers → Copilot**, or with `gh pr edit NUMBER --add-reviewer @copilot` (quote
  `'@copilot'` in PowerShell). Re-request it after you push fixes.
- Automatic reviews can run on creation, on new pushes, and on drafts; set them with rulesets or in your
  personal Copilot settings.
- Copilot leaves **Comment** reviews by default. Copilot approvals are generally available but off until
  an admin turns them on.
- Work through comments by applying suggestions, using **Fix with Copilot** or **Add to batch**, replying
  with `@copilot`, or declining with a reason.
- Review instructions come from `copilot-instructions.md`, path-specific files (`excludeAgent` decides which
  agent sees them), agent files, and **`REVIEW.md`**, all read from the **head branch**. Keep each file
  short; current guidance is about 1,000 lines at most.
- Each review costs AI Credits plus Actions minutes.
