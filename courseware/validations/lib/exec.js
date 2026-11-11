import { spawnSync } from 'node:child_process';
import { join } from 'node:path';

const isWin = process.platform === 'win32';

/**
 * Run a command synchronously and capture its output; returns { code, stdout, stderr, output }.
 * stdin is closed so nothing can block on a prompt.
 */
export function run(command, args, { cwd, timeout = 300_000, env } = {}) {
  const r = spawnSync(command, args, {
    cwd,
    encoding: 'utf8',
    shell: isWin,
    timeout,
    stdio: ['ignore', 'pipe', 'pipe'],
    env: env ? { ...process.env, ...env } : process.env,
  });
  const stdout = r.stdout || '';
  const stderr = r.stderr || '';
  return { code: r.status, stdout, stderr, output: `${stdout}\n${stderr}`, error: r.error };
}

/** Run a sample's test suite the way a student would. */
export function runTests(lang, cwd) {
  if (lang === 'dotnet') {
    return run('dotnet', ['test'], { cwd });
  }
  // Maven Wrapper: mvnw.cmd on Windows, called by absolute path because cmd.exe may be configured not
  // to search the current directory (NoDefaultCurrentDirectoryInExePath). On macOS/Linux call it
  // through `sh`, because a copy made on Windows (or a checkout without the executable bit) can't be
  // run as ./mvnw directly.
  return isWin
    ? run(`"${join(cwd, 'mvnw.cmd')}"`, ['-B', '-q', 'test'], { cwd })
    : run('sh', ['./mvnw', '-B', '-q', 'test'], { cwd });
}

/**
 * Pull the names of the failing tests out of a test run's output.
 *  - dotnet test (Microsoft.Testing.Platform):  `failed Ns.Class.Method(args) (3ms)`
 *  - Maven Surefire:                             `[ERROR]   Class.method:33 ...`
 * ANSI color codes are stripped first: on a CI runner Microsoft.Testing.Platform colors its output
 * (`\x1b[31mfailed\x1b[m Ns.Class.Method`), which would otherwise hide every name from the pattern.
 */
export function failingTests(lang, output) {
  const names = new Set();
  const plain = output.replace(/\x1b\[[0-9;]*m/g, '');
  const pattern = lang === 'dotnet' ? /^failed ([\w.]+)/gm : /^\[ERROR\]\s+(\w+\.\w+):\d+/gm;
  for (const m of plain.matchAll(pattern)) names.add(m[1]);
  return [...names];
}
