# Choosing a Model

Almost everything in this module so far has been about the harness, and the model picker is the
exception: it's the one control that swaps the model while leaving the harness, your context, and your
tools exactly as they were. That makes it a useful experiment, since the same prompt against two models
tells you a lot about whether a bad answer was a context problem or a reasoning problem. It's also a
cost decision, because Copilot now bills by the token.

---

## The model picker

Every Copilot surface lets you choose the model, though the control looks a little different on each:

| Surface | Where you choose |
|---|---|
| VS Code | The **Language model** control in the Chat view |
| Copilot CLI | `/model` during a session, or `--model` when you start one (`auto` is a valid value) |
| GitHub.com chat | The model dropdown, which can also regenerate an answer with another model |
| Cloud agent | A model dropdown when you assign an issue to Copilot or start a task from the Agents tab |

The menu spans several vendors. GitHub's supported-models list currently includes models from OpenAI,
Anthropic, Google, Microsoft, Moonshot, and xAI, in sizes from small, fast models to large ones built
for long, careful reasoning. GitHub sets the menu and changes it often, so check the picker rather than
a list in a course document.

Some surfaces add a second dial for *reasoning effort*, which controls how long the model thinks before
it answers. VS Code offers it in the model picker for models that support it, the cloud agent shows a
reasoning-level dropdown next to the model for those models, and the CLI takes `--reasoning-effort`
with values from `none` up to `max`.

---

## Auto

**Auto** picks the model for you, request by request. Behind the scenes it combines a system-health
signal with an evaluation of how complex the task looks, and it can reroute to a different model at a
cache boundary or when the complexity shifts sharply. In VS Code, hover over a response to see which
model answered it.

Three details matter in practice:

- On paid plans, Auto qualifies for a 10% discount on model costs in Copilot Chat and the cloud agent.
- You're billed for whichever model Auto actually picked, at that model's rate.
- Auto has three routing profiles, **Efficiency**, **Balance**, and **Intelligence**, whose names
  describe the trade-off each one favors. VS Code shows them in an **Optimize for** menu where the
  service offers it, and in the CLI you set the profile with `--auto-tier` or the `COPILOT_AUTO_TIER`
  environment variable.

Where the cloud agent offers no model picker, it uses Auto. For most day-to-day work in this course,
Auto is a sensible default.

Your picker may show **Copilot Fusion** as well, or in Auto's place. It went generally available in
October 2026 in VS Code, the CLI, the Copilot app, and JetBrains IDEs. Where Auto picks one model per
request, Fusion can also run several on one task (a cheap model drafts and another checks the draft,
for example), and you're billed for every model it uses at that model's rate. Its Standard tier is on
every plan, and for this course you can treat it the way you'd treat Auto.

---

## What a request costs: AI Credits

Since June 1, 2026, Copilot bills in **AI Credits**, and one credit is worth one cent. Usage is metered
by tokens at each model's API rate, so a long agent session on a large model costs more than a short
question on a small one. Code completions and Next Edit Suggestions in the editor don't use credits.
Each plan includes a monthly allotment, and the individual plans add a variable "flex" amount on top
of the base:

| Plan | Price | Included AI Credits a month |
|---|---|---|
| Pro | $10/month | 1,500 (1,000 base + 500 flex) |
| Pro+ | $39/month | 7,000 (3,900 base + 3,100 flex) |
| Max | $100/month | 20,000 (10,000 base + 10,000 flex) |
| Business | $19/user/month | 1,900 per user, pooled across the organization |
| Enterprise | $39/user/month | 3,900 per user, pooled across the organization |

When your credits run out, Copilot doesn't fall back to a cheaper model, so it's worth knowing roughly
what your sessions use.

If you've read older material, you'll see *premium requests* and *multipliers*. That's the legacy
billing model. It still applies to annual Pro and Pro+ plans until they expire, and accounts on it see
a request multiplier in the picker instead of token prices, but new work is billed in AI Credits.

### Seeing the cost

VS Code and the CLI both show what you're spending. In VS Code, hover over a model in the picker to see
its cost per token type, hover over a response to see the credits that turn used, and open the context
window control in the chat input for the session's total. In the CLI, the `/model` picker shows each
model's per-token cost for input, cached input, and output, `/usage` shows the AI Credits the current
session has used, and `--max-ai-credits` sets a ceiling for a run.

```powershell
copilot --model auto      # start a session on Auto, then type /usage at any point
```

Agent mode deserves a moment's thought here. Every turn of the agent loop is another model call that
carries the growing conversation with it, so one agent task can cost many times what a single chat
answer does. The `chat.agent.maxRequests` setting (25 by default) is a safety net, and a well-scoped
prompt is the better one. The cloud agent also draws on your GitHub Actions compute entitlement on top
of the tokens it uses.

---

## Fast or strong: making the call

Which model is best depends on the task in front of you. Smaller, faster models (the "nano," "Flash,"
or "Haiku" end of each family) are quick and cheap, and they're good at work where the answer is
mostly in the context you supplied. Larger models cost more per token and take longer, but they hold
more of a problem in mind at once and make fewer reasoning mistakes on subtle code.

| Task | A reasonable first choice |
|---|---|
| Explain a method, rename a symbol, write a doc comment | A fast model, or Auto |
| Generate tests for clearly stated rules | Auto |
| A multi-file change, a subtle bug, or a plan for a feature | A stronger model |
| Review unfamiliar business rules, such as fee or discount policies | A stronger model |
| The agent keeps looping or misreading the code | Switch to a stronger model and retry |

A practical rhythm is to start with Auto, step up to a stronger model when the agent struggles, and
step down for mechanical edits. If a stronger model gives the same wrong answer, look at the context
instead; the model probably never saw what it needed.

---

## Bring your own key

*BYOK* ("bring your own key") lets Copilot call a model through your own provider account instead of
GitHub's, which helps when your team already has a provider agreement or wants a model GitHub doesn't
offer.

In VS Code, run **Chat: Manage Language Models**. Built-in providers include Azure, Anthropic, Gemini,
and OpenAI, among others, plus a custom endpoint for any service that speaks the Chat Completions,
Responses, or Messages API. Business and Enterprise users need their admin to enable the policy **Bring
Your Own Language Model Key in VS Code** first. BYOK covers chat and utility tasks only, so inline
suggestions, semantic search, and embeddings still go through GitHub. In Copilot harness sessions, BYOK
models also need the experimental `chat.agentHost.byokModels.enabled` setting turned on.

The Copilot CLI reads BYOK settings from environment variables (`copilot help providers` lists them):

```powershell
$env:COPILOT_PROVIDER_TYPE     = "azure"        # openai | azure | anthropic
$env:COPILOT_PROVIDER_BASE_URL = "<your endpoint URL>"
$env:COPILOT_PROVIDER_API_KEY  = "<your key>"
$env:COPILOT_MODEL             = "<your deployment or model name>"
copilot
```

The Copilot app supports BYOK as well. Where the models run is a separate question that matters to many
tech leads, and GitHub documents it per vendor; the course's conclusion compares that with OpenCode
and Kiro.

---

## Summary

- The model picker changes the model and nothing else, which makes it a good test of whether a problem
  is context or reasoning.
- Choose the model in VS Code's **Language model** control, with `/model` or `--model` in the CLI, and
  from dropdowns on GitHub.com and in the cloud agent.
- **Auto** picks a model per task, with Efficiency, Balance, and Intelligence profiles and a 10%
  discount on paid plans; you pay the rate of the model it chose. **Copilot Fusion** can also combine
  several models on one task, and bills each one.
- Copilot bills in **AI Credits** (one cent each) by the token; premium requests and multipliers are
  legacy, and completions don't use credits.
- Use fast models for explanation and mechanical edits and stronger ones for multi-file changes,
  subtle bugs, and planning.
- BYOK lets you use your own provider key, via **Chat: Manage Language Models** in VS Code or the
  `COPILOT_PROVIDER_*` variables in the CLI.
