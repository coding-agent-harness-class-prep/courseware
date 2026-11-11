import { fileURLToPath } from 'node:url';
import { dirname, resolve, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url)); // courseware/validations/lib

// The courseware root (two levels up from validations/lib).
export const COURSEWARE = resolve(here, '..', '..');

/** Absolute path to an artifact folder given a courseware-relative path. */
export const artifactPath = (rel) => join(COURSEWARE, rel);
