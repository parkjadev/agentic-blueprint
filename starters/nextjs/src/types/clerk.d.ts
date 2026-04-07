import type { UserRole } from '.';

// Extend Clerk's JWT session claims with custom metadata
declare global {
  interface CustomJwtSessionClaims {
    metadata?: {
      role?: UserRole;
    };
  }
}

export {};
