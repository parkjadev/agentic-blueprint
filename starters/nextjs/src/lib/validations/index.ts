import { z } from 'zod';

/**
 * Pagination query parameter schema.
 * Defaults: page = 1, pageSize = 20, max pageSize = 100.
 */
export const paginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  pageSize: z.coerce.number().int().positive().max(100).default(20),
});

/**
 * UUID path parameter schema.
 */
export const uuidSchema = z.string().uuid('Invalid ID format');

/**
 * Sort order schema.
 */
export const sortOrderSchema = z.enum(['asc', 'desc']).default('desc');

/**
 * Common string field validations.
 */
export const nameSchema = z.string().min(1, 'Name is required').max(255, 'Name is too long');
export const emailSchema = z.string().email('Invalid email address');

/**
 * Parse search params into a typed pagination object.
 */
export function parsePagination(searchParams: URLSearchParams) {
  return paginationSchema.parse({
    page: searchParams.get('page'),
    pageSize: searchParams.get('pageSize'),
  });
}
