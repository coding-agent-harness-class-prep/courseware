#!/usr/bin/env node
/*
 * preprocess.mjs — turns an authored deck (../md/NN-*.md) into a Marp-ready
 * Markdown stream on stdout.
 *
 * The authored decks keep the original, tool-agnostic convention (see AGENTS.md,
 * "Slide deck"): a YAML block with title/subtitle/author, `#` headings as section-divider
 * slides, `##` headings as content slides, and NO `---` rules. Marp instead
 * needs `marp: true` front matter and `---` between every slide. This script
 * bridges the two so authors never hand-write Marp scaffolding.
 *
 * What it does:
 *   1. Reads the leading YAML front matter (title / subtitle / author).
 *   2. Emits Marp front matter (theme, pagination, footer) + a title slide.
 *   3. Inserts a `---` slide break before every `#` / `##` heading.
 *   4. Tags `#` slides with class `section` and the title slide with `title`.
 *   5. Is fence-aware: `#` lines *inside* ``` code fences (e.g. a bash comment)
 *      are left alone, never treated as slide breaks.
 *   6. Inlines diagram images as base64 `data:` URIs (see below).
 *
 * Why images are inlined:
 *   Marp runs against a COPY of this output in a throwaway `mktemp -d`, so a
 *   relative path like ../../diagrams/png/x.png would resolve against /tmp and
 *   404 — and Marp renders a missing image silently, with no build error. Rather
 *   than fight the path, we read the file here and embed it. That also means the
 *   generated .pptx is self-contained and `--allow-local-files` is never needed.
 *   The authored path stays relative so the deck still renders on GitHub.
 *
 * Usage:  node preprocess.mjs <input.md>   > <output.md>
 * Env:    DIAGRAMS_DIR   where ../../diagrams/ is mounted (default /diagrams)
 */

import { readFileSync } from "node:fs";
import { basename, join } from "node:path";

const COURSE = "GitHub Copilot as a Coding-Agent Harness";

const path = process.argv[2];
if (!path) {
  console.error("usage: node preprocess.mjs <input.md>");
  process.exit(1);
}

const raw = readFileSync(path, "utf8").replace(/\r\n/g, "\n");
const lines = raw.split("\n");

// --- 0. Diagram inlining -------------------------------------------------
const DIAGRAMS_DIR = process.env.DIAGRAMS_DIR || "/diagrams";

const MIME = {
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
};

/**
 * Turn `![alt](../../diagrams/png/x.png)` into `![alt](data:image/png;base64,…)`.
 *
 * Only diagram paths are rewritten; anything else (a remote URL, an existing
 * data: URI) is passed through untouched. A referenced-but-missing diagram is a
 * hard error — Marp would otherwise emit a blank slide and exit 0.
 */
function inlineImages(line, srcName) {
  return line.replace(/!\[([^\]]*)\]\(([^)\s]+)\)/g, (whole, alt, src) => {
    const m = src.match(/(?:^|\/)diagrams\/(.+)$/);
    if (!m) return whole;

    const file = join(DIAGRAMS_DIR, m[1]);
    const ext = m[1].slice(m[1].lastIndexOf(".")).toLowerCase();
    const mime = MIME[ext];
    if (!mime) {
      console.error(`ERROR: ${srcName}: unsupported image type "${ext}" (${src})`);
      process.exit(1);
    }

    let bytes;
    try {
      bytes = readFileSync(file);
    } catch {
      console.error(
        `ERROR: ${srcName}: diagram not found: ${src}\n` +
          `       looked in ${file}\n` +
          `       Build it first (see courseware/diagrams/README.md), or fix the path.`
      );
      process.exit(1);
    }
    return `![${alt}](data:${mime};base64,${bytes.toString("base64")})`;
  });
}

const srcName = basename(path);

// --- 1. Peel off the leading YAML front matter, if present ---------------
const meta = {};
let bodyStart = 0;
if (lines[0].trim() === "---") {
  let i = 1;
  for (; i < lines.length; i++) {
    if (lines[i].trim() === "---") {
      i++;
      break;
    }
    const m = lines[i].match(/^([A-Za-z][\w-]*):\s*(.*)$/);
    if (m) {
      let val = m[2].trim();
      if (
        (val.startsWith('"') && val.endsWith('"')) ||
        (val.startsWith("'") && val.endsWith("'"))
      ) {
        val = val.slice(1, -1);
      }
      meta[m[1]] = val;
    }
  }
  bodyStart = i;
}

const title = meta.title || "Untitled";
const subtitle = meta.subtitle || "";
const author = meta.author || "";
// The footer shows the course name on every content slide.
const footer = COURSE;

// --- 2. Emit Marp front matter + title slide -----------------------------
const out = [];
out.push("---");
out.push("marp: true");
out.push("theme: courseware");
out.push("paginate: true");
out.push(`footer: "${footer.replace(/"/g, '\\"')}"`);
out.push("---");
out.push("");
out.push("<!-- _class: title -->");
out.push("<!-- _paginate: false -->");
out.push("");
out.push(`# ${title}`);
out.push("");
if (subtitle) {
  out.push(`## ${subtitle}`);
  out.push("");
}
if (author) {
  out.push(author);
  out.push("");
}

// --- 3. Walk the body, inserting slide breaks at headings ----------------
let inFence = false;
for (let i = bodyStart; i < lines.length; i++) {
  const line = lines[i];

  // Track fenced code blocks so headings inside them are left untouched.
  if (/^\s*```/.test(line)) {
    inFence = !inFence;
    out.push(line);
    continue;
  }

  if (!inFence) {
    const h1 = /^# (?!#)/.test(line); // section divider
    const h2 = /^## (?!#)/.test(line); // content slide
    if (h1 || h2) {
      out.push("---");
      out.push("");
      if (h1) {
        out.push("<!-- _class: section -->");
        out.push("<!-- _paginate: false -->");
        out.push("");
      }
      out.push(line);
      continue;
    }
  }

  // Inside a fence an image reference is literal sample text — leave it alone.
  out.push(inFence ? line : inlineImages(line, srcName));
}

// Collapse any accidental run of blank lines to keep the output tidy.
const text = out.join("\n").replace(/\n{3,}/g, "\n\n");
process.stdout.write(text.endsWith("\n") ? text : text + "\n");
