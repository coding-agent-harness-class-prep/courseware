// print.cjs — runs INSIDE the container. Prints a self-contained HTML file to PDF
// by driving the base image's headless Chrome through puppeteer-core (the DevTools
// protocol), rather than Chrome's `--print-to-pdf` CLI flag, which hangs without
// ever writing the file in some container/WSL environments.
//
// puppeteer-core is provided by the marp-cli base image; entrypoint.sh points
// NODE_PATH at that image's node_modules so `require` can resolve it.
//
// Usage: node print.cjs <input.html> <output.pdf>

const puppeteer = require('puppeteer-core');

const [htmlPath, pdfPath] = process.argv.slice(2);
if (!htmlPath || !pdfPath) {
  console.error('Usage: node print.cjs <input.html> <output.pdf>');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: process.env.CHROME_PATH || '/usr/local/bin/chrome',
    headless: true,
    args: ['--no-sandbox', '--disable-gpu', '--disable-dev-shm-usage'],
  });
  try {
    const page = await browser.newPage();
    await page.goto('file://' + htmlPath, { waitUntil: 'load' });
    await page.pdf({
      path: pdfPath,
      printBackground: true,
      format: 'Letter',
      preferCSSPageSize: true,
      margin: { top: '0.5in', bottom: '0.5in', left: '0.6in', right: '0.6in' },
    });
  } finally {
    await browser.close();
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
