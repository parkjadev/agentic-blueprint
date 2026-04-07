import { SignJWT, jwtVerify } from 'jose';
import { env } from '@/env';

const JWT_ISSUER = 'app';
const JWT_AUDIENCE = 'mobile';
const JWT_EXPIRY = '7d';

function getSecret(): Uint8Array {
  const secret = env.MOBILE_JWT_SECRET;
  if (!secret) {
    throw new Error('MOBILE_JWT_SECRET is not configured');
  }
  return new TextEncoder().encode(secret);
}

type MobileTokenPayload = {
  userId: string;
  email: string;
  role: string;
};

/**
 * Sign a JWT for mobile app authentication.
 * Called after validating credentials (e.g., email + password login).
 */
export async function signMobileJwt(payload: MobileTokenPayload): Promise<string> {
  return new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuer(JWT_ISSUER)
    .setAudience(JWT_AUDIENCE)
    .setIssuedAt()
    .setExpirationTime(JWT_EXPIRY)
    .sign(getSecret());
}

/**
 * Verify a mobile JWT and extract the payload.
 * Used by get-auth.ts when a Bearer token is present.
 */
export async function verifyMobileJwt(token: string): Promise<MobileTokenPayload> {
  const { payload } = await jwtVerify(token, getSecret(), {
    issuer: JWT_ISSUER,
    audience: JWT_AUDIENCE,
  });

  return {
    userId: payload.userId as string,
    email: payload.email as string,
    role: payload.role as string,
  };
}
