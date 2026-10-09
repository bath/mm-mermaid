// Capture demo.html frame by frame. Usage: node record.mjs <out-dir> [fps]
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { join, dirname } from 'node:path';

const outDir = process.argv[2];
const fps = Number(process.argv[3] ?? 30);
mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1280, height: 800 }, deviceScaleFactor: 2 });
const here = dirname(fileURLToPath(import.meta.url));
await page.goto(pathToFileURL(join(here, 'demo.html')).href);
await page.waitForFunction(() => document.querySelector('#preview img').complete);

const length = await page.evaluate(() => window.DEMO_LENGTH);
const frames = Math.ceil(length * fps);
for (let i = 0; i < frames; i++) {
  await page.evaluate(t => window.render(t), i / fps);
  await page.screenshot({ path: join(outDir, `${String(i).padStart(5, '0')}.png`) });
}
await browser.close();
console.log(`${frames} frames → ${outDir}`);
