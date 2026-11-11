// Prove the courseware's cross-references hold: every relative link and image in every Markdown
// file resolves to a real file, and every diagram exists in all three committed formats.
//
// A mass edit (renumbering a module, renaming a sample) breaks links silently; GitHub renders a
// dead link as an ordinary link. This is the check that catches it before a student clicks one.
import { describe, it, expect } from 'vitest';
import { readdirSync, readFileSync, existsSync, statSync } from 'node:fs';
import { join, dirname, resolve, relative, extname, basename } from 'node:path';
import { COURSEWARE } from '../lib/paths.js';

const REPO = resolve(COURSEWARE, '..');
const SKIP_DIRS = new Set(['node_modules', '.git', 'bin', 'obj', 'target', 'pptx', 'pdf', 'png', 'svg']);

function markdownFiles(dir) {
  const found = [];
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) {
      if (!SKIP_DIRS.has(name)) found.push(...markdownFiles(full));
    } else if (extname(name) === '.md') {
      found.push(full);
    }
  }
  return found;
}

/** Relative link and image targets in a Markdown file, outside fenced code blocks and inline code. */
function relativeTargets(file) {
  const text = readFileSync(file, 'utf8')
    .replace(/^(```|~~~)[\s\S]*?^\1/gm, '')
    .replace(/`[^`\n]*`/g, '');
  const targets = [];
  for (const m of text.matchAll(/!?\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)) {
    const target = m[1];
    if (/^(https?:|mailto:|#)/.test(target)) continue;
    targets.push(decodeURIComponent(target.split('#')[0]));
  }
  return targets;
}

const files = [
  join(REPO, 'README.md'),
  ...markdownFiles(COURSEWARE).filter((f) => !f.includes(`${join('courseware', 'validations')}`)),
];

describe('relative links resolve', () => {
  for (const file of files) {
    const targets = relativeTargets(file);
    if (targets.length === 0) continue;
    it(relative(REPO, file).replaceAll('\\', '/'), () => {
      const broken = targets.filter((t) => !existsSync(resolve(dirname(file), t)));
      expect(broken, `broken links in ${relative(REPO, file)}`).toEqual([]);
    });
  }
});

describe('diagrams exist in all three formats', () => {
  const stems = (folder, ext) =>
    readdirSync(join(COURSEWARE, 'diagrams', folder))
      .filter((f) => f.endsWith(ext))
      .map((f) => basename(f, ext))
      .sort();

  it('svg, png, and pdf hold the same NN-slug stems', () => {
    const svg = stems('svg', '.svg');
    expect(stems('png', '.png')).toEqual(svg);
    expect(stems('pdf', '.pdf')).toEqual(svg);
  });
});
