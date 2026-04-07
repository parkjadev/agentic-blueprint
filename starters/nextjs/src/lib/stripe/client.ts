import Stripe from 'stripe';
import { env, services } from '@/env';

/**
 * Stripe client instance.
 * Returns null if Stripe is not configured (opt-in service).
 */
function createStripeClient(): Stripe | null {
  if (!services.stripe || !env.STRIPE_SECRET_KEY) {
    return null;
  }

  return new Stripe(env.STRIPE_SECRET_KEY, {
    apiVersion: '2025-02-24.acacia',
    typescript: true,
  });
}

export const stripe = createStripeClient();
