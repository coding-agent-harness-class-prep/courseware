// Extract the visible text of a PDF, one array of lines per page.
//
// Used by unit/slides.test.js to prove that no generated slide is CLIPPED.
// Marp does not shrink content to fit — anything taller than the slide is
// simply cut off, and the cut is invisible in the Markdown source. The only
// honest signal is what actually landed on the rendered page.
//
// pdfjs-dist (Mozilla's PDF.js) is used instead of shelling out to poppler's
// `pdftotext`: it is a normal npm devDependency, so the check runs anywhere
// `npm install` runs, with no system package to install first.
import { readFileSync } from 'node:fs';
import { createRequire, } from 'node:module';
import { pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);

// The "legacy" build is the one meant for Node — the default build assumes
// browser globals (DOMMatrix, Path2D) that Node does not provide.
// `require.resolve` gives a plain path; on Windows that must become a file://
// URL before dynamic import will accept it.
const pdfjsPath = 'pdfjs-dist/legacy/build/pdf.mjs';

let pdfjs;
async function getPdfjs() {
  if (!pdfjs) pdfjs = await import(pathToFileURL(require.resolve(pdfjsPath)).href);
  return pdfjs;
}

/**
 * Read a PDF and return its text as `string[][]` — one array of trimmed,
 * non-empty lines per page, in page order.
 *
 * PDF text is a bag of positioned runs, not lines, so runs are grouped back
 * into lines by their baseline (the `y` translation of the text matrix).
 */
export async function pdfPageLines(file) {
  const { getDocument } = await getPdfjs();

  const task = getDocument({
    data: new Uint8Array(readFileSync(file)),
    // Slide decks carry no fillable forms, and skipping the font/eval setup
    // keeps the whole 13-deck sweep to a couple of seconds.
    isEvalSupported: false,
    useSystemFonts: false,
  });
  const doc = await task.promise;

  const pages = [];
  for (let n = 1; n <= doc.numPages; n++) {
    const page = await doc.getPage(n);
    const { items } = await page.getTextContent();

    // Bucket runs by baseline. Rounding absorbs sub-pixel jitter between runs
    // that are visually on the same line (e.g. inline `code` spans).
    const byLine = new Map();
    for (const item of items) {
      if (typeof item.str !== 'string' || !item.str.trim()) continue;
      const y = Math.round(item.transform[5]);
      const x = item.transform[4];
      if (!byLine.has(y)) byLine.set(y, []);
      byLine.get(y).push({ x, str: item.str });
    }

    const lines = [...byLine.entries()]
      .sort((a, b) => b[0] - a[0]) // PDF y grows upward; top line first
      .map(([, runs]) =>
        runs
          .sort((a, b) => a.x - b.x)
          .map((r) => r.str)
          .join('')
          .trim()
      )
      .filter(Boolean);

    pages.push(lines);
    page.cleanup();
  }

  await task.destroy();
  return pages;
}
