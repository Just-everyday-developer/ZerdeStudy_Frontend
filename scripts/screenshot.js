// Drive the Flutter web app via Playwright and capture screenshots.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE = process.env.BASE_URL || 'http://localhost:8765';
const OUT = path.resolve(__dirname, '..', 'output', '25.05');

const VIEWPORT = { width: 1600, height: 1000 };

async function waitForFlutter(page) {
  // Wait until Flutter view has rendered something — give it a generous timeout.
  await page.waitForFunction(() => {
    const view = document.querySelector('flutter-view') || document.querySelector('flt-glass-pane') || document.body;
    if (!view) return false;
    const rect = view.getBoundingClientRect();
    return rect.width > 100 && rect.height > 100;
  }, { timeout: 60_000 });
  await page.waitForTimeout(1500);
}

async function shot(page, name) {
  fs.mkdirSync(OUT, { recursive: true });
  const file = path.join(OUT, `${name}.png`);
  await page.screenshot({ path: file, fullPage: false });
  console.log('saved', file);
}

const EMAIL = 'talgatomyrkanov@gmail.com';
const PASSWORD = 'talgat2006';

async function loginViaUi(page) {
  await page.goto(BASE + '/login', { waitUntil: 'load' });
  await waitForFlutter(page);
  await page.waitForTimeout(2000);

  // Flutter web renders text via a hidden DOM input on focus. Click the
  // canvas at the approximate email field location, then type.
  // Click the email field — it's the first TextField on the login panel.
  const viewport = page.viewportSize();
  const cx = viewport.width / 2;

  // Coordinates calibrated from the rendered login panel at 1600×1000.
  await page.mouse.click(cx, 446);
  await page.waitForTimeout(400);
  await page.keyboard.type(EMAIL, { delay: 25 });

  await page.mouse.click(cx, 514);
  await page.waitForTimeout(400);
  await page.keyboard.type(PASSWORD, { delay: 25 });

  await page.mouse.click(cx, 580);
  await page.waitForTimeout(5000);
}

async function navigate(page, route) {
  // Use the browser History API so GoRouter picks it up without a hard reload
  // that would re-trigger session bootstrap and reset our place.
  await page.evaluate((r) => {
    window.history.pushState({}, '', r);
    window.dispatchEvent(new PopStateEvent('popstate'));
  }, route);
  await page.waitForTimeout(2500);
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: VIEWPORT, deviceScaleFactor: 1 });
  const page = await context.newPage();

  // First go to the login page and authenticate via the real form
  await loginViaUi(page);

  // Step 1: home (we land here after login)
  await navigate(page, '/home');
  await page.waitForTimeout(2500);
  await shot(page, '01_home');

  // Step 2: knowledge tree
  await navigate(page, '/tree');
  await page.waitForTimeout(3000);
  await shot(page, '02_knowledge_tree');

  // Step 3: OOP track from the tree
  await navigate(page, '/track/oop');
  await page.waitForTimeout(3000);
  await shot(page, '03_oop_track');

  // Step 4: OOP practice (code editor)
  await navigate(page, '/practice/oop_practice_1');
  await page.waitForTimeout(3000);
  await shot(page, '04_oop_code_editor');

  // Step 5: SQL community course (external SQL course)
  await navigate(page, '/courses/course_sql_for_analysts');
  await page.waitForTimeout(3000);
  await shot(page, '05_sql_course');

  // Step 6: Statistics with metrics
  await navigate(page, '/stats');
  await page.waitForTimeout(3000);
  await shot(page, '06_stats');

  await browser.close();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
