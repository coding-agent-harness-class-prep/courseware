# Instructor

Everything here is for the person teaching the session; students don't need any of it.

| File | What it is |
|---|---|
| [`TEACHING-GUIDE.md`](TEACHING-GUIDE.md) | The itinerary: the four-hour agenda, the 25 + 25 module rhythm, prep timeline, and facilitation notes |
| [`COURSE-MAP.md`](COURSE-MAP.md) | The map: each outline bullet resolved to its chapter, deck, demo step, activity task, and diagram, plus the counts table |

## Before you teach

1. **A week out,** send [`setup/setup-student-machines.md`](../setup/setup-student-machines.md) to the
   team preparing the environment. It covers the VM software *and* the accounts' Copilot seats and
   policies, and the second half matters as much as the first. Publish the two orders samples as public
   repositories in your organization for students to clone (the teaching guide has the commands).
2. **Dry-run on a student VM** with a test account: copy a sample into the account with the
   [student quick start](../setup/student-quick-start.md), open a pull request in it, request a Copilot
   code review, start the CLI. A policy that's switched off usually shows up only when
   you try the feature it controls.
3. **Rehearse the four demos** on the VS Code and CLI builds you'll use. Each demo README's
   **Before class** section lists its setup, and the teaching guide says when each step happens:
   Demo 03's two cloud runs start at least 30 minutes before Module 3, Demo 04's cloud-sandbox session
   runs the morning of, and Demo 04's failing test is pushed during Activity 02, after Demo 02.
4. **Run the validation harness** if you've changed any sample, solution, or deck:
   `cd courseware/validations; npm ci; npm test`.

## Keeping these in sync

The teaching guide answers *when*; the course map answers *what goes with what*. Don't copy the map into
the guide. When content changes, update the map's rows and its counts table in the same change.
