import type { AuthUser } from '@/types';

/**
 * Seed factory for test data.
 * Generates typed test objects without hitting the database.
 * Use these in unit tests that mock the data layer.
 */

let idCounter = 0;

function nextId(): string {
  idCounter++;
  // Deterministic UUID-like string for tests
  return `00000000-0000-0000-0000-${String(idCounter).padStart(12, '0')}`;
}

/** Reset the ID counter between test suites */
export function resetFactories() {
  idCounter = 0;
}

// --- User factory ---

type UserOverrides = Partial<AuthUser>;

export function createTestUser(overrides: UserOverrides = {}): AuthUser {
  const id = overrides.id ?? nextId();
  return {
    id,
    email: overrides.email ?? `user-${id}@test.example.com`,
    name: overrides.name ?? `Test User ${id}`,
    role: overrides.role ?? 'user',
    status: overrides.status ?? 'active',
  };
}

export function createTestAdmin(overrides: UserOverrides = {}): AuthUser {
  return createTestUser({ role: 'admin', ...overrides });
}

// --- Project factory ---

type TestProject = {
  id: string;
  name: string;
  description: string | null;
  ownerId: string;
  status: 'active' | 'archived' | 'deleted';
  createdAt: Date;
  updatedAt: Date;
};

type ProjectOverrides = Partial<TestProject>;

export function createTestProject(
  owner: AuthUser,
  overrides: ProjectOverrides = {},
): TestProject {
  const id = overrides.id ?? nextId();
  const now = new Date('2026-01-01T00:00:00Z');
  return {
    id,
    name: overrides.name ?? `Test Project ${id}`,
    description: overrides.description ?? null,
    ownerId: overrides.ownerId ?? owner.id,
    status: overrides.status ?? 'active',
    createdAt: overrides.createdAt ?? now,
    updatedAt: overrides.updatedAt ?? now,
  };
}

// --- Request/Response helpers ---

export function createMockRequest(
  url: string,
  options: {
    method?: string;
    body?: unknown;
    headers?: Record<string, string>;
  } = {},
): Request {
  const { method = 'GET', body, headers = {} } = options;

  return new Request(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...headers,
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
}

export async function parseJsonResponse<T>(response: Response): Promise<{
  status: number;
  body: T;
}> {
  const body = (await response.json()) as T;
  return { status: response.status, body };
}
