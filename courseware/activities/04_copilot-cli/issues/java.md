Finance reconciled last month's orders and found a handful where we charged one cent less sales tax
than finance policy FIN-7 says we should. It's always exactly one cent, never more.

## Example

An order shipped to **TX** for one `CAB-USBC` cable (8.40) is charged **0.52** in tax. Finance expects
**0.53**: 8.40 × 6.25% is exactly 0.525, and FIN-7 says an exact half cent rounds up.

## Reproduction

`src/test/java/com/example/orders/pricing/TaxCalculatorTest.java` reproduces it.
`calculate_exactHalfCent_roundsUp` fails and the other tax tests pass:

```powershell
.\mvnw.cmd test
```

## Expected

- Tax rounds to the nearest cent, and an exact half cent rounds **up** (FIN-7).
- The failing test passes and every other test still passes.
- Fix the cause in the production code; don't change the test's expectations.
