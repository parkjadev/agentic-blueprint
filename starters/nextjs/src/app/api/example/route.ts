import { NextRequest } from 'next/server';
import { z } from 'zod';
import { eq, desc, sql, and } from 'drizzle-orm';
import { db } from '@/lib/db';
import { projects } from '@/lib/db/schema';
import { getAuth } from '@/lib/auth/get-auth';
import { ok, created, handleError, ApiError } from '@/lib/api-response';
import { parsePagination, nameSchema } from '@/lib/validations';
import { getRequestContext } from '@/lib/request-context';
import { checkRateLimit, publicRateLimiter, writeRateLimiter } from '@/lib/rate-limit';

// GET /api/example — list projects (public, paginated)
export async function GET(request: NextRequest) {
  try {
    const { ip } = await getRequestContext();
    const { success } = await checkRateLimit(ip, publicRateLimiter);
    if (!success) {
      throw ApiError.rateLimited();
    }

    const { searchParams } = request.nextUrl;
    const { page, pageSize } = parsePagination(searchParams);
    const offset = (page - 1) * pageSize;

    const [items, countResult] = await Promise.all([
      db
        .select()
        .from(projects)
        .where(eq(projects.status, 'active'))
        .orderBy(desc(projects.createdAt))
        .limit(pageSize)
        .offset(offset),
      db
        .select({ count: sql<number>`count(*)` })
        .from(projects)
        .where(eq(projects.status, 'active')),
    ]);

    const total = Number(countResult[0]?.count ?? 0);

    return ok({
      data: items,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    });
  } catch (error) {
    return handleError(error, { path: '/api/example', method: 'GET' });
  }
}

// POST /api/example — create a project (auth required)
const createSchema = z.object({
  name: nameSchema,
  description: z.string().max(2000).optional(),
});

export async function POST(request: NextRequest) {
  try {
    const user = await getAuth();
    if (!user) {
      throw ApiError.unauthorised();
    }

    const { ip } = await getRequestContext();
    const { success } = await checkRateLimit(`${user.id}:write`, writeRateLimiter);
    if (!success) {
      throw ApiError.rateLimited();
    }

    const body = await request.json();
    const { name, description } = createSchema.parse(body);

    // Check for duplicate name per owner
    const existing = await db.query.projects.findFirst({
      where: and(
        eq(projects.ownerId, user.id),
        eq(projects.name, name),
        eq(projects.status, 'active'),
      ),
    });

    if (existing) {
      throw ApiError.conflict('A project with this name already exists');
    }

    const [project] = await db
      .insert(projects)
      .values({
        name,
        description: description ?? null,
        ownerId: user.id,
      })
      .returning();

    return created(project, {
      path: '/api/example',
      method: 'POST',
      userId: user.id,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return handleError(
        ApiError.badRequest(error.errors[0]?.message ?? 'Validation failed'),
        { path: '/api/example', method: 'POST' },
      );
    }
    return handleError(error, { path: '/api/example', method: 'POST' });
  }
}
