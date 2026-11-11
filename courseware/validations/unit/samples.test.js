// Prove every sample app, every reference solution, and every planted bug behaves the way the
// demos and activities say it will. See lib/manifest.js for the scenario list.
import { describe, it, expect } from 'vitest';
import { scenarios, samples } from '../lib/manifest.js';
import { prepareWorkspace, disposeWorkspace } from '../lib/workspace.js';
import { runTests, failingTests } from '../lib/exec.js';

describe('sample apps, solutions, and planted bugs', () => {
  for (const scenario of scenarios) {
    it(scenario.id, () => {
      const { lang } = samples[scenario.sample];
      const workspace = prepareWorkspace(scenario.sample, scenario.overlays);
      try {
        const result = runTests(lang, workspace);
        const tail = result.output.slice(-4000);

        if (scenario.expect === 'pass') {
          expect(result.code, `expected a green test run\n${tail}`).toBe(0);
          return;
        }

        expect(result.code, `expected the test run to FAIL\n${tail}`).not.toBe(0);
        const failed = failingTests(lang, result.output);
        expect(failed.length, `no failing test names found in the output\n${tail}`).toBeGreaterThan(0);
        for (const name of failed) {
          expect(name, `an unexpected test failed\n${tail}`).toMatch(scenario.failingTest);
        }
      } finally {
        disposeWorkspace(workspace);
      }
    });
  }
});
