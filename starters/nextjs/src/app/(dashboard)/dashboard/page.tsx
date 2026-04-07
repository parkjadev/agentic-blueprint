import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';

export default async function DashboardPage() {
  const { userId } = await auth();

  if (!userId) {
    redirect('/sign-in');
  }

  return (
    <main className="mx-auto max-w-4xl px-4 py-12">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      <p className="mt-4 text-gray-600">
        Welcome to your dashboard. This is a protected page — only authenticated users can see it.
      </p>

      {/* TODO: Add your dashboard content here */}
      <div className="mt-8 rounded-lg border border-gray-200 bg-gray-50 p-8 text-center">
        <p className="text-sm text-gray-500">
          Your app content goes here. See the example API at{' '}
          <code className="rounded bg-gray-200 px-2 py-1 text-xs">/api/example</code>{' '}
          for backend patterns.
        </p>
      </div>
    </main>
  );
}
