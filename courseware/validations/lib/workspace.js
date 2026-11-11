import { cpSync, existsSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, join } from 'node:path';
import { artifactPath } from './paths.js';

// Build output that must never be copied into a scenario's workspace.
const BUILD_DIRS = new Set(['bin', 'obj', 'target', 'TestResults', 'node_modules']);

const skipBuildOutput = (src) => !BUILD_DIRS.has(basename(src));

/**
 * Copy a sample into a fresh temp folder and lay each overlay folder on top of it.
 * Returns the workspace path. The caller removes it with `disposeWorkspace`.
 */
export function prepareWorkspace(sample, overlays) {
  const source = artifactPath(join('samples', sample));
  if (!existsSync(source)) throw new Error(`sample not found: samples/${sample}`);

  const workspace = mkdtempSync(join(tmpdir(), `courseware-${sample}-`));
  cpSync(source, workspace, { recursive: true, filter: skipBuildOutput });

  for (const overlay of overlays) {
    const from = artifactPath(overlay);
    if (!existsSync(from)) throw new Error(`overlay not found: ${overlay}`);
    cpSync(from, workspace, { recursive: true, force: true });
  }
  return workspace;
}

/** Remove a workspace created by `prepareWorkspace` (only ever a path under the OS temp folder). */
export function disposeWorkspace(workspace) {
  if (workspace && workspace.startsWith(tmpdir()) && basename(workspace).startsWith('courseware-')) {
    rmSync(workspace, { recursive: true, force: true, maxRetries: 3 });
  }
}
