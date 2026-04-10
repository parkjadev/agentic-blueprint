/**
 * Doc-drift test — lightweight assertions that tie code state to documentation.
 *
 * The pattern: pick one or two "code → doc" pairs where drift is silent and
 * costly, then assert they match in CI. This catches stale docs *before* they
 * confuse an operator or an LLM agent.
 *
 * This test is illustrative of the *pattern*, not a recipe to copy verbatim.
 * Adapt the assertions to your own doc/code pairs. Good candidates:
 *   - package.json version ↔ CHANGELOG.md heading
 *   - env vars in src/env.ts ↔ deployment.md env-vars table
 *   - API routes in src/app/api/** ↔ api-reference.md
 *
 * The Sentinel learning was: a domain enum (vertical statuses) drifted from
 * CHANGELOG content and nobody noticed for weeks. A one-line assertion would
 * have caught it in CI. This test is the generic version of that lesson —
 * never domain-specific, always portable.
 */

import { describe, it, expect } from 'vitest';
import { readFileSync } from 'fs';
import { resolve } from 'path';

const ROOT = resolve(__dirname, '..', '..', '..');

function readFile(relativePath: string): string {
  return readFileSync(resolve(ROOT, relativePath), 'utf-8');
}

describe('doc-drift', () => {
  it('package.json version appears as a CHANGELOG heading', () => {
    const pkg = JSON.parse(readFile('package.json'));
    const changelog = readFile('CHANGELOG.md');

    const { version } = pkg as { version: string };

    // The version should appear either as:
    //   ## [X.Y.Z]    — a released version heading
    //   ## [Unreleased] — the working section (if version is "0.1.0" and
    //                      nothing has been released yet, [Unreleased] is fine)
    const hasVersionHeading = changelog.includes(`## [${version}]`);
    const hasUnreleasedSection = changelog.includes('## [Unreleased]');

    expect(
      hasVersionHeading || hasUnreleasedSection,
      `Expected CHANGELOG.md to contain a heading for version ${version} ` +
        `(either "## [${version}]" or "## [Unreleased]"). ` +
        `If you bumped the version in package.json, update CHANGELOG.md too.`,
    ).toBe(true);
  });
});
