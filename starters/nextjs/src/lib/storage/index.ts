import { env, services } from '@/env';

type UploadResult = {
  key: string;
  url: string;
};

/**
 * Upload a file to Cloudflare R2.
 * Gracefully skips if R2 is not configured.
 */
export async function uploadFile(
  key: string,
  body: ReadableStream | Buffer | string,
  contentType: string,
): Promise<UploadResult | null> {
  if (!services.r2) {
    return null;
  }

  const url = `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com/${env.R2_BUCKET_NAME}/${key}`;

  // Convert Buffer to Uint8Array — Node.js fetch types don't accept Buffer
  // in the body parameter directly (Buffer is missing URLSearchParams methods
  // that BodyInit requires). Uint8Array is the standard portable type.
  const fetchBody: BodyInit = Buffer.isBuffer(body)
    ? new Uint8Array(body)
    : body;

  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': contentType,
      Authorization: `Bearer ${env.R2_ACCESS_KEY_ID}:${env.R2_SECRET_ACCESS_KEY}`,
    },
    body: fetchBody,
  });

  if (!response.ok) {
    throw new Error(`R2 upload failed: ${response.status} ${response.statusText}`);
  }

  return {
    key,
    url: `https://${env.R2_BUCKET_NAME}.r2.dev/${key}`,
  };
}

/**
 * Delete a file from Cloudflare R2.
 */
export async function deleteFile(key: string): Promise<void> {
  if (!services.r2) {
    return;
  }

  const url = `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com/${env.R2_BUCKET_NAME}/${key}`;

  await fetch(url, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${env.R2_ACCESS_KEY_ID}:${env.R2_SECRET_ACCESS_KEY}`,
    },
  });
}
