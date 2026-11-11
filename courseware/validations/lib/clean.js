// Remove the build output that running the samples in place leaves behind: .NET bin/ obj/
// TestResults/ and Maven target/ under courseware/samples, plus this harness's own temp
// workspaces if a run was interrupted before it could dispose of them.
//
// NEVER deletes git-tracked files: anything tracked is skipped, so a committed file can't be
// lost to a clean.
import { rmSync, existsSync, readdirSync, statSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { COURSEWARE } from './paths.js';

const BUILD_DIRS = new Set(['bin', 'obj', 'target', 'TestResults']);

let tracked = new Set();
try {
  const out = execFileSync('git', ['ls-files', '-z'], { cwd: COURSEWARE, encoding: 'utf8' });
  tracked = new Set(out.split('\0').filter(Boolean).map((p) => join(COURSEWARE, p)));
} catch {
  console.warn('warning: could not list git-tracked files; skipping tracked-file guard');
}
const containsTracked = (dir) => [...tracked].some((t) => t.startsWith(dir + '\\') || t.startsWith(dir + '/'));

let removed = 0;

function purge(dir) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (!statSync(full).isDirectory()) continue;
    if (BUILD_DIRS.has(name) && !containsTracked(full)) {
      rmSync(full, { recursive: true, force: true });
      removed++;
    } else if (name !== 'node_modules' && name !== '.git') {
      purge(full);
    }
  }
}

const samples = join(COURSEWARE, 'samples');
if (existsSync(samples)) purge(samples);

// Leftover harness workspaces (see lib/workspace.js).
for (const name of readdirSync(tmpdir())) {
  if (name.startsWith('courseware-')) {
    rmSync(join(tmpdir(), name), { recursive: true, force: true });
    removed++;
  }
}

console.log(`cleaned ${removed} build-output folder(s)`);
