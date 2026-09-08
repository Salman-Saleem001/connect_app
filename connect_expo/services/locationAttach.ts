/**
 * Chat location send — Firestore fields match Flutter MessageType.location.
 */
import { sendChatMessage } from '@/services/chat';

export type LocationAttachCtx = {
  chatsId: string;
  from: string;
  to: string;
  videoId: number;
};

export type LocationPayload = {
  latitude: number;
  longitude: number;
  address: string;
};

export async function sendChatLocation(
  ctx: LocationAttachCtx,
  location: LocationPayload,
) {
  await sendChatMessage({
    chatRoomId: ctx.chatsId,
    from: ctx.from,
    to: ctx.to,
    videoId: ctx.videoId,
    message: 'Location',
    messageType: 'location',
    files: [],
    voiceData: {
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
    },
  });
}
