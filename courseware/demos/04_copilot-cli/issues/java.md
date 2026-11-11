A member borrowed a book on Saturday 20 June and was told to bring it back on Sunday 5 July. We're
closed on Sundays, so they couldn't, and on Monday they were charged as late at the desk.

## Expected

A loan is never due on a day the library is closed. The due date moves forward to the next day we're
open (see "Lending rules in brief" in the README). Saturday 4 July was a library holiday as well.

## Reproduction

`src/test/java/com/example/library/lending/DueDateCalculatorTest.java` reproduces it.
`dueDate_skipsConsecutiveClosedDays` fails and the other due-date tests pass:

```powershell
.\mvnw.cmd test
```

## Done when

- The failing test passes and every other test still passes.
- The fix is in the production code; the test's expectations don't change.
