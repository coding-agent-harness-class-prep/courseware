import { defineConfig } from 'vitest/config';

// Each sample scenario shells out to a real `dotnet test` or Maven Wrapper build, which is CPU- and
// disk-heavy and shares the NuGet and Maven caches, so the specs run serially (`maxWorkers: 1`,
// `fileParallelism: false`) with generous timeouts. A first run on a cold cache downloads every
// package; later runs reuse the caches and are much quicker.
//
// Vitest 4 note: `poolOptions` was REMOVED in Vitest 4 and its contents promoted to top-level.
// Vitest 4 does not error on the old shape -- it SILENTLY IGNORES it -- so serial execution is
// expressed here as `maxWorkers: 1` + `isolate: false`. See https://vitest.dev/guide/migration
export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['unit/**/*.test.js'],
    testTimeout: 420_000,
    hookTimeout: 180_000,
    fileParallelism: false,
    pool: 'forks',
    maxWorkers: 1,
    isolate: false,
    reporters: ['default'],
  },
});
