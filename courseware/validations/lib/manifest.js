// What the harness proves, and how.
//
// Every scenario starts from a pristine copy of one sample app, lays zero or more overlay folders on
// top of it (each overlay mirrors the sample's own paths, so laying it on is a plain copy), and runs
// the sample's real test suite. That is exactly what a student does in class: copy the sample, then
// add files from an activity's assets/ folder, or compare against its solution/.
//
//   expect: 'pass'  the suite must succeed
//   expect: 'fail'  the suite must fail, and ONLY on tests whose name matches `failingTest` -- a
//                   repro test that fails for the wrong reason (or alongside an unrelated failure)
//                   would teach the wrong lesson in Module 4
//
// Adding a demo or activity that ships code means adding its scenarios here. Nothing else changes.

export const samples = {
  'orders-dotnet': { lang: 'dotnet', role: 'activity app' },
  'orders-java': { lang: 'java', role: 'activity app' },
  'library-dotnet': { lang: 'dotnet', role: 'demo app' },
  'library-java': { lang: 'java', role: 'demo app' },
};

const A = {
  chat: 'activities/01_chat-with-context',
  agent: 'activities/02_agent-mode-and-instructions',
  cloud: 'activities/03_cloud-agent-and-review',
  cli: 'activities/04_copilot-cli',
};

const D = {
  chat: 'demos/01_harness-and-chat',
  agent: 'demos/02_agent-mode-customization',
  cloud: 'demos/03_cloud-agent-code-review',
  cli: 'demos/04_copilot-cli',
};

function activityScenarios(lang) {
  const sample = `orders-${lang}`;
  return [
    { id: `${sample}: baseline is green`, sample, overlays: [], expect: 'pass' },
    { id: `${sample}: activity 01 reference tests pass`, sample, overlays: [`${A.chat}/solution/${lang}`], expect: 'pass' },
    {
      id: `${sample}: activity 02 customization files + reference rule pass`,
      sample,
      overlays: [`${A.agent}/assets/${lang}`, `${A.agent}/solution/${lang}`],
      expect: 'pass',
    },
    { id: `${sample}: activity 03 reference implementation passes`, sample, overlays: [`${A.cloud}/solution/${lang}`], expect: 'pass' },
    {
      id: `${sample}: activity 04 repro test fails on the half-cent case only`,
      sample,
      overlays: [`${A.cli}/assets/${lang}`],
      expect: 'fail',
      failingTest: lang === 'dotnet' ? /Calculate_ExactHalfCent_RoundsUp/ : /calculate_exactHalfCent_roundsUp/,
    },
    {
      id: `${sample}: activity 04 repro test + reference fix pass`,
      sample,
      overlays: [`${A.cli}/assets/${lang}`, `${A.cli}/solution/${lang}`],
      expect: 'pass',
    },
  ];
}

function demoScenarios(lang) {
  const sample = `library-${lang}`;
  return [
    { id: `${sample}: baseline is green`, sample, overlays: [], expect: 'pass' },
    { id: `${sample}: demo 01 reference tests pass`, sample, overlays: [`${D.chat}/solution/${lang}`], expect: 'pass' },
    {
      id: `${sample}: demo 02 customization files + reference rule pass`,
      sample,
      overlays: [`${D.agent}/assets/${lang}`, `${D.agent}/solution/${lang}`],
      expect: 'pass',
    },
    { id: `${sample}: demo 03 reference implementation passes`, sample, overlays: [`${D.cloud}/solution/${lang}`], expect: 'pass' },
    {
      id: `${sample}: demo 04 repro test fails on consecutive closed days only`,
      sample,
      overlays: [`${D.cli}/assets/${lang}`],
      expect: 'fail',
      failingTest: lang === 'dotnet' ? /DueDate_SkipsConsecutiveClosedDays/ : /dueDate_skipsConsecutiveClosedDays/,
    },
    {
      id: `${sample}: demo 04 repro test + reference fix pass`,
      sample,
      overlays: [`${D.cli}/assets/${lang}`, `${D.cli}/solution/${lang}`],
      expect: 'pass',
    },
  ];
}

export const scenarios = [
  ...activityScenarios('dotnet'),
  ...activityScenarios('java'),
  ...demoScenarios('dotnet'),
  ...demoScenarios('java'),
];
