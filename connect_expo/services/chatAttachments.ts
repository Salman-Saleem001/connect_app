/**
 * Chat attachment helpers — gallery / location / voice.
 * Documents live in `documentAttach.ts` (PDF / Word / Excel).
 */
import {
  sendChatMessage,
  uploadChatImage,
  uploadChatVoice,
  uploadInChatVideo,
} from '@/services/chat';
import * as ImagePicker from 'expo-image-picker';
import { Alert } from 'react-native';

export type AttachCtx = {
  chatsId: string;
  from: string;
  to: string;
  videoId: number;
};

export async function pickAndSendPhotos(ctx: AttachCtx) {
  const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
  if (!perm.granted) {
    Alert.alert('', 'Photo library permission is required.');
    return;
  }
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ['images'],
    allowsMultipleSelection: true,
    quality: 0.85,
    selectionLimit: 4,
  });
  if (result.canceled || !result.assets?.length) return;

  const urls: string[] = [];
  for (let i = 0; i < result.assets.length; i++) {
    const uploaded = await uploadChatImage(ctx.chatsId, result.assets[i]!.uri, i);
    urls.push(uploaded.url);
  }
  await sendChatMessage({
    chatRoomId: ctx.chatsId,
    from: ctx.from,
    to: ctx.to,
    videoId: ctx.videoId,
    message: '',
    messageType: 'image',
    files: urls,
    voiceData: null,
  });
}

export async function pickAndSendGalleryVideo(ctx: AttachCtx) {
  const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
  if (!perm.granted) {
    Alert.alert('', 'Photo library permission is required.');
    return;
  }
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ['videos'],
    quality: 1,
  });
  if (result.canceled || !result.assets?.[0]) return;

  const asset = result.assets[0];
  const uploaded = await uploadInChatVideo(ctx.chatsId, asset.uri);
  await sendChatMessage({
    chatRoomId: ctx.chatsId,
    from: ctx.from,
    to: ctx.to,
    videoId: ctx.videoId,
    message: 'Video',
    messageType: 'video',
    files: [],
    voiceData: {
      url: uploaded.url,
      duration: Math.round((asset.duration ?? 0) / 1000),
      fileSize: uploaded.fileSize,
    },
  });
}

export async function sendRecordedVoice(
  ctx: AttachCtx,
  localUri: string,
  durationSeconds: number,
) {
  if (durationSeconds < 1) {
    Alert.alert('', 'Hold a bit longer to record a voice message.');
    return;
  }
  const uploaded = await uploadChatVoice(ctx.chatsId, localUri);
  await sendChatMessage({
    chatRoomId: ctx.chatsId,
    from: ctx.from,
    to: ctx.to,
    videoId: ctx.videoId,
    message: 'Voice message',
    messageType: 'voice',
    files: [],
    voiceData: {
      url: uploaded.url,
      duration: Math.round(durationSeconds),
      fileSize: uploaded.fileSize,
    },
  });
}
