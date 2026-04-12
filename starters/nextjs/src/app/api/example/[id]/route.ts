import { NextRequest } from 'next/server';
import { z } from 'zod';
import { eq } from 'drizzle-orm';
import { db } from '@/lib/db';
import { projects } from '@/lib/db/schema';
import { getAuth } from '@/lib/auth/get-auth';
import { ok, noContent, handleError, ApiError } from '@/lib/api-response';
import { uuidSchema, nameSchema } from '@/lib/validations';

import { checkRateLimit, writeRateLimiter } from '@/lib/rate-limit';

type RouteParams = { params: Promise<{ id: string }> };

// Resolve a project by ID, checking ownership for non-admins
async function resolveProject(id: string, userId?: string, requireOwner = false) {
  const projectId = uuidSchema.parse(id);

  const project = await db.query.projects.findFirst({
    where: eq(projects.id, projectId),
  });

  if (!project || project.status === 'deleted') {
    throw ApiError.notFound('Project not found');
  }

  if (requireOwner && userId && project.ownerId !== userId) {
    throw ApiError.forbidden('You do not own this project');
  }

  return project;
}

// GET /api/example/[id] — get a single project (auth required)
export async function GET(_request: NextRequest, { params }: RouteParams) {
  try {
    const user = await getAuth();
    if (!user) {
      throw ApiError.unauthorised();
    }

    const { id } = await params;
    const project = await resolveProject(id);

    // Non-admins can only see their own projects
    if (user.role !== 'admin' && project.ownerId !== user.id) {
      throw ApiError.forbidden('You do not own this project');
    }

    return ok(project, {
      path: `/api/example/${id}`,
      method: 'GET',
      userId: user.id,
    });
  } catch (error) {
    return handleError(error, { path: '/api/example/[id]', method: 'GET' });
  }
}

// PUT /api/example/[id] — update a project (owner or admin)
const updateSchema = z.object({
  name: nameSchema.optional(),
  description: z.string().max(2000).optional(),
});

export async function PUT(request: NextRequest, { params }: RouteParams) {
  try {
    const user = await getAuth();
    if (!user) {
      throw ApiError.unauthorised();
    }

    const { success } = await checkRateLimit(`${user.id}:write`, writeRateLimiter);
    if (!success) {
      throw ApiError.rateLimited();
    }

    const { id } = await params;
    const project = await resolveProject(
      id,
      user.role !== 'admin' ? user.id : undefined,
      user.role !== 'admin',
    );

    const body = await request.json();
    const updates = updateSchema.parse(body);

    const [updated] = await db
      .update(projects)
      .set({
        ...updates,
        updatedAt: new Date(),
      })
      .where(eq(projects.id, project.id))
      .returning();

    return ok(updated, {
      path: `/api/example/${id}`,
      method: 'PUT',
      userId: user.id,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return handleError(
        ApiError.badRequest(error.errors[0]?.message ?? 'Validation failed'),
        { path: '/api/example/[id]', method: 'PUT' },
      );
    }
    return handleError(error, { path: '/api/example/[id]', method: 'PUT' });
  }
}

// DELETE /api/example/[id] — soft-delete a project (owner or admin)
export async function DELETE(_request: NextRequest, { params }: RouteParams) {
  try {
    const user = await getAuth();
    if (!user) {
      throw ApiError.unauthorised();
    }

    const { success } = await checkRateLimit(`${user.id}:write`, writeRateLimiter);
    if (!success) {
      throw ApiError.rateLimited();
    }

    const { id } = await params;
    const project = await resolveProject(
      id,
      user.role !== 'admin' ? user.id : undefined,
      user.role !== 'admin',
    );

    // Soft delete — set status to 'deleted'
    await db
      .update(projects)
      .set({ status: 'deleted', updatedAt: new Date() })
      .where(eq(projects.id, project.id));

    return noContent({
      path: `/api/example/${id}`,
      method: 'DELETE',
      userId: user.id,
    });
  } catch (error) {
    return handleError(error, { path: '/api/example/[id]', method: 'DELETE' });
  }
}
