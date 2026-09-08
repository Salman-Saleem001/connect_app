/**
 * Auto-generate media thumbnails — mirrors Flutter `VideoThumbnail.thumbnailFile`.
 */
import * as VideoThumbnails from 'expo-video-thumbnails';

/** Generate a still frame from a local/remote video URI. */
export async function generateVideoThumbnail(
  videoUri: string,
  timeMs = 500,
): Promise<string | null> {
  if (!videoUri) return null;
  try {
    const result = await VideoThumbnails.getThumbnailAsync(videoUri, {
      time: timeMs,
      quality: 0.9,
    });
    return result.uri;
  } catch {
    return null;
  }
}

/** For images the source itself is the thumbnail. */
export function imageAsThumbnail(imageUri: string): string {
  return imageUri;
}
