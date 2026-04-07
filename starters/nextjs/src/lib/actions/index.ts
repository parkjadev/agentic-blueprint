import { auth } from '@clerk/nextjs/server';
import { logger } from '@/lib/logger';

type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string };

/**
 * Wrapper for server actions that handles errors consistently.
 * Use for public actions that don't require authentication.
 */
export async function action<T>(
  fn: () => Promise<T>,
): Promise<ActionResult<T>> {
  try {
    const data = await fn();
    return { success: true, data };
  } catch (error) {
    const message = error instanceof Error ? error.message : 'An unexpected error occurred';
    logger.error('Action failed', { error: message });
    return { success: false, error: message };
  }
}

/**
 * Wrapper for server actions that require authentication.
 * Resolves the current user via Clerk before executing the action.
 */
export async function authAction<T>(
  fn: (userId: string) => Promise<T>,
): Promise<ActionResult<T>> {
  try {
    const { userId } = await auth();

    if (!userId) {
      return { success: false, error: 'Unauthenticated' };
    }

    const data = await fn(userId);
    return { success: true, data };
  } catch (error) {
    const message = error instanceof Error ? error.message : 'An unexpected error occurred';
    logger.error('Auth action failed', { error: message });
    return { success: false, error: message };
  }
}
