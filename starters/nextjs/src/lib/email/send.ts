import { Resend } from 'resend';
import { env, services } from '@/env';
import { logger } from '@/lib/logger';

const resend = services.resend ? new Resend(env.RESEND_API_KEY) : null;

type SendEmailParams = {
  to: string | string[];
  subject: string;
  html: string;
  from?: string;
};

/**
 * Send a transactional email via Resend.
 * Gracefully skips if Resend is not configured — logs the attempt instead.
 */
export async function sendEmail({ to, subject, html, from }: SendEmailParams): Promise<void> {
  if (!resend) {
    logger.info('Email skipped (Resend not configured)', { to, subject });
    return;
  }

  const { error } = await resend.emails.send({
    from: from ?? 'App <noreply@example.com>', // TODO: Update sender address
    to: Array.isArray(to) ? to : [to],
    subject,
    html,
  });

  if (error) {
    logger.error('Failed to send email', { to, subject, error: error.message });
    throw new Error(`Email send failed: ${error.message}`);
  }

  logger.info('Email sent', { to, subject });
}
