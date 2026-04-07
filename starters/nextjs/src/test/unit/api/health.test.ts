import { describe, it, expect } from 'vitest';
import { GET } from '@/app/api/health/route';

describe('GET /api/health', () => {
  it('returns status ok with a timestamp', async () => {
    const response = await GET();
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body).toHaveProperty('status', 'ok');
    expect(body).toHaveProperty('timestamp');

    // Timestamp should be a valid ISO 8601 string
    const parsed = new Date(body.timestamp);
    expect(parsed.toISOString()).toBe(body.timestamp);
  });

  it('returns valid JSON content type', async () => {
    const response = await GET();
    const contentType = response.headers.get('content-type');

    expect(contentType).toContain('application/json');
  });
});
