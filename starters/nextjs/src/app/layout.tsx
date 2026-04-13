import type { Metadata } from 'next';
import { Providers } from './providers';
import '@/app/globals.css';

export const metadata: Metadata = {
  title: 'App', // TODO: Update with your app name
  description: 'Built with the Agentic Blueprint starter',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-background font-sans antialiased">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
