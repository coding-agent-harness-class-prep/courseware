// build.mjs — runs INSIDE the container (see Containerfile / entrypoint.sh).
//
// Converts one Markdown outline file into a styled, self-contained HTML file
// that headless Chrome then prints to PDF. The Markdown is the source of record;
// the HTML is a throwaway intermediate and the PDF is the deliverable.
//
// Usage: node build.mjs <input.md> <output.html>

import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { marked } from 'marked';

const [, , inPath, outPath] = process.argv;
if (!inPath || !outPath) {
  console.error('Usage: node build.mjs <input.md> <output.html>');
  process.exit(1);
}

const here = dirname(fileURLToPath(import.meta.url));
const css = readFileSync(join(here, 'outline.css'), 'utf8');

let md = readFileSync(inPath, 'utf8');

// Derive the page <title> from the front-matter `title:` (falling back to the first H1),
// so the tool stays file-driven and works for any outline dropped into md/.
const frontMatter = (md.match(/^---\r?\n([\s\S]*?)\r?\n---/) || [])[1] || '';
const fmTitle = ((frontMatter.match(/^\s*title:\s*(.+?)\s*$/m) || [])[1] || '').trim();
const h1Title = ((md.match(/^#\s+(.+?)\s*$/m) || [])[1] || '').trim();
const pageTitle = (fmTitle || h1Title || 'Course Outline').replace(/&/g, '&amp;');

// Strip the YAML front matter (metadata for other tools; not rendered here).
md = md.replace(/^---\r?\n[\s\S]*?\r?\n---\r?\n/, '');

const body = marked.parse(md);

const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>${pageTitle} — Course Outline</title>
  <style>${css}</style>
</head>
<body>
${body}
</body>
</html>
`;

writeFileSync(outPath, html);
