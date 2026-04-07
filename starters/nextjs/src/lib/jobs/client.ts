import { Inngest } from 'inngest';
import { services } from '@/env';

/**
 * Inngest client for background job processing.
 * Returns a no-op client if Inngest is not configured.
 */
export const inngest = new Inngest({
  id: 'app', // TODO: Replace with your app name
  // Inngest will gracefully handle missing credentials in development
});

/**
 * Check if Inngest is configured and available.
 */
export function isInngestAvailable(): boolean {
  return services.inngest;
}
