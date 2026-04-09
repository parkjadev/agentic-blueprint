# Post-Deploy Hook Patterns

Automation patterns for verifying deployments after they complete. These can be configured as Claude Code hooks or as scheduled tasks.

---

## Overview

Post-deploy verification ensures that a deployment is healthy before you move on. These patterns range from a simple health check to a full smoke test suite.

---

## Pattern 1: Health Check

The simplest verification — hit the health endpoint and check the response.

> The blueprint uses GitHub Flow with one long-lived branch (`main`) and a Vercel preview deployment per PR. The hook examples below assume that model. There is no `staging` branch — preview URLs are your "staging".

### As a Claude Code Hook

Run after every `git push` to `main` (i.e. after a squash-merge lands):

```json
{
  "hooks": {
    "post-push": [
      {
        "command": "sleep 30 && curl -sf https://your-domain.com/api/health || echo 'DEPLOY HEALTH CHECK FAILED'",
        "description": "Verify production health after push to main",
        "blocking": false
      }
    ]
  }
}
```

### As a Manual Check

After merging to `main`:

```bash
# Wait for Vercel to finish deploying (check Vercel dashboard or MCP)
curl -sf https://your-domain.com/api/health
# Expected: {"status":"ok","timestamp":"..."}
```

### As a Scheduled Task Prompt

```
Check the latest deployment for this repository.
Hit the /api/health endpoint at the production URL.
If it returns a non-200 response or takes longer than 5 seconds:
1. Check the Vercel deployment logs for errors
2. Create a GitHub issue with the error details
3. Label it as "bug" and "urgent"

If the health check passes, do nothing (silent success).
```

---

## Pattern 2: Endpoint Smoke Test

Verify that key API endpoints respond correctly after deployment.

### Smoke Test Script

Create a script that tests critical paths:

```typescript
// scripts/smoke-test.ts
// Default to production; pass SMOKE_TEST_URL=<preview-url> to run against a PR preview.
const BASE_URL = process.env.SMOKE_TEST_URL ?? 'https://your-domain.com';

type TestCase = {
  name: string;
  method: string;
  path: string;
  expectedStatus: number;
};

const tests: TestCase[] = [
  { name: 'Health check', method: 'GET', path: '/api/health', expectedStatus: 200 },
  { name: 'Public list', method: 'GET', path: '/api/example', expectedStatus: 200 },
  { name: 'Unauthed create', method: 'POST', path: '/api/example', expectedStatus: 401 },
  { name: 'Not found', method: 'GET', path: '/api/example/00000000-0000-0000-0000-000000000000', expectedStatus: 401 },
];

async function run() {
  let failures = 0;

  for (const test of tests) {
    const response = await fetch(`${BASE_URL}${test.path}`, { method: test.method });

    if (response.status === test.expectedStatus) {
      console.log(`✓ ${test.name} — ${response.status}`);
    } else {
      console.error(`✗ ${test.name} — expected ${test.expectedStatus}, got ${response.status}`);
      failures++;
    }
  }

  if (failures > 0) {
    console.error(`\n${failures} test(s) failed.`);
    process.exit(1);
  }

  console.log('\nAll smoke tests passed.');
}

run();
```

### Usage

```bash
# Against a PR preview (run before merging)
SMOKE_TEST_URL=https://your-project-pr-42.vercel.app pnpm tsx scripts/smoke-test.ts

# Against production (run immediately after merging to main)
SMOKE_TEST_URL=https://your-domain.com pnpm tsx scripts/smoke-test.ts
```

### As a Hook

```json
{
  "hooks": {
    "post-push": [
      {
        "command": "sleep 45 && SMOKE_TEST_URL=https://your-domain.com pnpm tsx scripts/smoke-test.ts",
        "description": "Run smoke tests after production deploy",
        "blocking": false
      }
    ]
  }
}
```

---

## Pattern 3: Deployment Status via Vercel MCP

Use the Vercel MCP integration to check deployment status programmatically.

### Scheduled Task Prompt

```
Check the latest production deployment for this repository using Vercel MCP.

1. Get the deployment status (building, ready, error)
2. If status is "error":
   - Read the build logs
   - Diagnose the failure
   - Create a GitHub issue with title "deploy: production deployment failed"
   - Include build logs and diagnosis in the issue
   - Label as "bug" and "urgent"
3. If status is "ready":
   - Check runtime logs for errors in the last 10 minutes
   - If error rate > 1%: create a GitHub issue flagging the error pattern
   - If clean: do nothing (silent success)
```

### In Claude Code

```
> Check the latest Vercel deployment for this project.
> Is it healthy? Any build errors or runtime errors in the last 10 minutes?
```

---

## Pattern 4: Database Migration Verification

After a deploy that includes schema changes, verify the migration applied correctly.

### Scheduled Task Prompt

```
After the latest deployment, verify database state:

1. Check if the latest migration was applied successfully
2. Query the new/modified tables to confirm they exist with correct columns
3. If any migration issues are found:
   - Create a GitHub issue with the details
   - Label as "bug" and "urgent"
   - Include the expected vs actual schema
```

### Manual Verification

```bash
# Connect to the deployed database and verify
pnpm db:studio
# Check that new tables/columns exist and have correct types
```

---

## Choosing a Pattern

| Scenario | Pattern | Surface |
|---|---|---|
| Every deploy, quick check | Pattern 1 (Health Check) | Hook or manual |
| After feature deploys | Pattern 2 (Smoke Test) | Hook or CI |
| Continuous monitoring | Pattern 3 (Vercel MCP) | Scheduled Task |
| Schema change deploys | Pattern 4 (Migration) | Manual or Scheduled Task |

## Tips

- **Start with Pattern 1.** A health check catches the most common failures (build errors, missing env vars, broken config) with minimal effort.
- **Don't block on post-deploy hooks.** Deployments take time. Use non-blocking hooks that report failures rather than blocking your workflow.
- **Sleep is a code smell.** Instead of `sleep 30 && curl`, prefer checking deployment status via Vercel MCP or polling the health endpoint with retries.
- **Escalate failures.** A failed deployment that nobody notices is worse than no automation. Always create an issue or notification on failure.
- **Test the happy path and the auth boundary.** The two most common post-deploy failures are: the app doesn't start (health check catches this) and auth is broken (smoke test catches this).
