import { createAdminClient } from '@/lib/supabase/server';

type UploadResult = {
  path: string;
  url: string;
};

/**
 * Upload a file to Supabase Storage.
 *
 * Uses the service-role client to bypass RLS. For user-scoped uploads,
 * configure storage bucket policies in the Supabase dashboard.
 */
export async function uploadFile(
  bucket: string,
  path: string,
  body: Buffer | Uint8Array | Blob,
  contentType: string,
): Promise<UploadResult> {
  const supabase = createAdminClient();

  const { error } = await supabase.storage
    .from(bucket)
    .upload(path, body, { contentType, upsert: true });

  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }

  const { data: urlData } = supabase.storage.from(bucket).getPublicUrl(path);

  return {
    path,
    url: urlData.publicUrl,
  };
}

/**
 * Delete a file from Supabase Storage.
 */
export async function deleteFile(bucket: string, path: string): Promise<void> {
  const supabase = createAdminClient();

  const { error } = await supabase.storage.from(bucket).remove([path]);

  if (error) {
    throw new Error(`Storage delete failed: ${error.message}`);
  }
}

/**
 * Get the public URL for a file in Supabase Storage.
 */
export function getPublicUrl(bucket: string, path: string): string {
  const supabase = createAdminClient();
  const { data } = supabase.storage.from(bucket).getPublicUrl(path);
  return data.publicUrl;
}
