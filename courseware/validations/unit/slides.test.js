// Prove that no generated slide is CLIPPED.
//
// Marp does not shrink content to fit. A slide whose body is taller than the
// 16:9 frame is silently cut off — the Markdown looks fine, the build prints no
// warning, and the missing lines are only visible if a human happens to page
// through the PDF. That is exactly the kind of defect that survives review, so
// it gets an automated check.
//
// The check compares each deck's Markdown source against the text that actually
// landed on the corresponding rendered page:
//
//   * page count      — pages must equal (title slide + one per `#`/`##`)
//   * page identity   — each page's first line must be its slide's heading
//   * line count      — a page must render at least as many lines as its slide
//                       body has (wrapping can only ADD lines; losing lines
//                       means the tail fell off the bottom)
//   * diagram exists  — every image a deck references resolves to a real file
//
// Images are deliberately EXCLUDED from the line count: a diagram contributes no
// text to the PDF, so counting its Markdown line would report a phantom clipped
// line on every slide that carries one. The existence check below is what
// replaces that coverage — a missing diagram is the failure that actually
// matters, and `preprocess.mjs` also hard-fails the build on it.
//
// It reads the committed PDFs, so it validates the artifact the instructor
// actually projects. If the PDFs are stale relative to the Markdown, the page
// count or heading check fails and the message says to re-run the pipeline.
import { describe, it, expect, beforeAll } from 'vitest';
import { readdirSync, readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { COURSEWARE } from '../lib/paths.js';
import { pdfPageLines } from '../lib/pdftext.js';

const MD_DIR = join(COURSEWARE, 'slides', 'md');
const PDF_DIR = join(COURSEWARE, 'slides', 'pdf');

const decks = readdirSync(MD_DIR)
  .filter((f) => f.endsWith('.md'))
  .sort();

/** Collapse a rendered or source line to comparable letters/digits. */
const norm = (s) =>
  s
    .replace(/^[\s>]*[-*+]\s+/, ' ')
    .replace(/[|`*_#>]/g, ' ')
    .replace(/[^\p{L}\p{N}]+/gu, '')
    .toLowerCase();

/**
 * Split a deck into slides. `#` and `##` both start a slide (the pipeline's
 * preprocessor turns `#` into a section divider and `##` into a content slide);
 * YAML front matter becomes the title slide and is not counted here.
 *
 * Body lines are counted the way Marp lays them out:
 *   - fence markers occupy no line of their own
 *   - a table's `|---|` separator row renders as a rule, not a line
 *   - a wrapped bullet continuation belongs to the bullet above it
 *   - an image line contributes no text, so it is collected into `images`
 *     instead of `body`
 */
const IMAGE_LINE = /^\s*!\[[^\]]*\]\(([^)\s]+)\)\s*$/;

function parseSlides(markdown) {
  const src = markdown.split(/\r?\n/);
  const slides = [];
  let cur = null;
  let inCode = false;
  let inFrontMatter = false;

  for (let i = 0; i < src.length; i++) {
    const line = src[i];

    if (i === 0 && line.trim() === '---') {
      inFrontMatter = true;
      continue;
    }
    if (inFrontMatter) {
      if (line.trim() === '---') inFrontMatter = false;
      continue;
    }

    if (/^```/.test(line)) {
      inCode = !inCode;
      continue;
    }

    if (!inCode && /^#{1,2} /.test(line)) {
      if (cur) slides.push(cur);
      cur = { title: line.replace(/^#{1,2} /, '').trim(), body: [], images: [] };
      continue;
    }
    if (!cur) continue;

    if (inCode) {
      if (line.trim()) cur.body.push({ text: line, code: true });
      continue;
    }

    if (!line.trim()) continue;
    if (/^\s*\|[\s:|-]+\|\s*$/.test(line)) continue; // table separator row

    // An image renders as a picture, not text — record it for the existence
    // check, but keep it out of the body budget.
    const img = line.match(IMAGE_LINE);
    if (img) {
      cur.images.push(img[1]);
      continue;
    }

    // Continuation of the bullet above — same rendered line, possibly wrapped.
    const last = cur.body.at(-1);
    if (/^\s+\S/.test(line) && last && !last.code && !/^\s*[-*+]\s/.test(line)) {
      last.text += ' ' + line.trim();
      continue;
    }

    cur.body.push({ text: line, code: false });
  }

  if (cur) slides.push(cur);
  return slides;
}

/** Drop the running footer + page number the theme stamps on every page. */
const stripFooter = (lines) =>
  lines.filter((l) => !/^GitHub Copilot as a Coding-Agent Harness\s*\d*$/i.test(l));

const rendered = {};

beforeAll(async () => {
  for (const deck of decks) {
    const pdf = join(PDF_DIR, deck.replace(/\.md$/, '.pdf'));
    if (existsSync(pdf)) rendered[deck] = await pdfPageLines(pdf);
  }
}, 120_000);

describe('every slide deck is rendered and complete', () => {
  for (const deck of decks) {
    describe(deck, () => {
      const slides = parseSlides(readFileSync(join(MD_DIR, deck), 'utf8'));

      it('has a generated PDF', () => {
        expect(
          existsSync(join(PDF_DIR, deck.replace(/\.md$/, '.pdf'))),
          `missing pdf/${deck.replace(/\.md$/, '.pdf')} — run slides/utils/convert.ps1`
        ).toBe(true);
      });

      it('renders one page per slide (plus the title slide)', () => {
        const pages = rendered[deck];
        expect(pages, 'PDF was not read').toBeTruthy();
        expect(
          pages.length,
          `${deck} has ${slides.length} slides but the PDF has ${pages.length} pages ` +
            `(expected ${slides.length + 1} incl. the title slide). ` +
            `The PDF is stale — re-run slides/utils/convert.ps1.`
        ).toBe(slides.length + 1);
      });

      // Images are excluded from the line count above, so this is the only thing
      // standing between a typo'd diagram path and a silently blank slide.
      it('references only diagrams that exist', () => {
        const missing = [];
        for (const slide of slides) {
          for (const src of slide.images) {
            if (/^(https?:|data:)/.test(src)) continue; // remote / already inline
            if (!existsSync(join(MD_DIR, src))) missing.push(`${slide.title} -> ${src}`);
          }
        }
        expect(
          missing,
          `${deck} references ${missing.length} diagram(s) that do not exist:\n` +
            missing.map((m) => `  ${m}`).join('\n') +
            `\nPaths are relative to slides/md/. Build the diagram (see ` +
            `courseware/diagrams/README.md) or fix the path.`
        ).toEqual([]);
      });

      for (let i = 0; i < slides.length; i++) {
        const slide = slides[i];
        const page = i + 2; // 1-based, offset by the title slide

        it(`p${page} "${slide.title}" is not clipped`, () => {
          const pages = rendered[deck];
          const lines = stripFooter(pages[i + 1] ?? []);

          expect(
            norm(lines[0] ?? ''),
            `page ${page} starts with "${lines[0]}" but slide ${i + 1} is ` +
              `"${slide.title}" — the PDF is stale or out of order.`
          ).toBe(norm(slide.title));

          const body = lines.length - 1; // minus the heading
          const expected = slide.body.length;

          // Wrapping can only ever ADD rendered lines. Fewer lines on the page
          // than in the source means Marp cut the bottom off the slide.
          expect(
            body,
            `page ${page} "${slide.title}" renders ${body} body lines but the ` +
              `source has ${expected} — ${expected - body} line(s) were clipped ` +
              `off the bottom. Split the slide into two.\n` +
              `  last source line: ${slide.body.at(-1)?.text.trim()}\n` +
              `  last rendered   : ${lines.at(-1)}`
          ).toBeGreaterThanOrEqual(expected);
        });
      }
    });
  }
});
