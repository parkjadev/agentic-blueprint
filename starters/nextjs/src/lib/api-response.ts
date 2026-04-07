import { NextResponse } from 'next/server';
import { logger } from '@/lib/logger';

type ApiLogContext = {
  path?: string;
  method?: string;
  userId?: string;
  duration?: number;
};

/**
 * Return a successful JSON response.
 */
export function ok<T>(data: T, logContext?: ApiLogContext): NextResponse {
  if (logContext) {
    logger.info('API response', { status: 200, ...logContext });
  }
  return NextResponse.json({ success: true, data }, { status: 200 });
}

/**
 * Return a successful JSON response for mobile clients.
 * Same as ok() but with explicit Cache-Control headers.
 */
export function mobileOk<T>(data: T, logContext?: ApiLogContext): NextResponse {
  if (logContext) {
    logger.info('API response (mobile)', { status: 200, ...logContext });
  }
  return NextResponse.json(
    { success: true, data },
    {
      status: 200,
      headers: { 'Cache-Control': 'no-store' },
    },
  );
}

/**
 * Return a 201 Created response.
 */
export function created<T>(data: T, logContext?: ApiLogContext): NextResponse {
  if (logContext) {
    logger.info('API response', { status: 201, ...logContext });
  }
  return NextResponse.json({ success: true, data }, { status: 201 });
}

/**
 * Return a 204 No Content response.
 */
export function noContent(logContext?: ApiLogContext): NextResponse {
  if (logContext) {
    logger.info('API response', { status: 204, ...logContext });
  }
  return new NextResponse(null, { status: 204 });
}

/**
 * Handle errors and return appropriate error responses.
 */
export function handleError(error: unknown, logContext?: ApiLogContext): NextResponse {
  if (error instanceof ApiError) {
    if (logContext) {
      logger.warn('API error', { status: error.status, message: error.message, ...logContext });
    }
    return NextResponse.json(
      { success: false, error: { message: error.message, code: error.code } },
      { status: error.status },
    );
  }

  const message = error instanceof Error ? error.message : 'Internal server error';
  logger.error('Unhandled API error', { error: message, ...logContext });

  return NextResponse.json(
    { success: false, error: { message: 'Internal server error', code: 'INTERNAL_ERROR' } },
    { status: 500 },
  );
}

/**
 * Custom API error class for controlled error responses.
 */
export class ApiError extends Error {
  constructor(
    public readonly status: number,
    message: string,
    public readonly code?: string,
  ) {
    super(message);
    this.name = 'ApiError';
  }

  static badRequest(message: string) {
    return new ApiError(400, message, 'VALIDATION_ERROR');
  }

  static unauthorised(message = 'Unauthenticated') {
    return new ApiError(401, message, 'UNAUTHENTICATED');
  }

  static forbidden(message = 'Forbidden') {
    return new ApiError(403, message, 'FORBIDDEN');
  }

  static notFound(message = 'Not found') {
    return new ApiError(404, message, 'NOT_FOUND');
  }

  static conflict(message: string) {
    return new ApiError(409, message, 'CONFLICT');
  }

  static rateLimited(message = 'Too many requests') {
    return new ApiError(429, message, 'RATE_LIMITED');
  }
}
