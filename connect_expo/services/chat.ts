import {
  addDoc,
  collection,
  doc,
  getDoc,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  type Unsubscribe,
} from 'firebase/firestore';
import { getDownloadURL, ref, uploadBytes } from 'firebase/storage';

import { db, storage } from '@/services/firebase';
import { readUriAsBlob } from '@/services/readLocalFile';
import type { MediaEdits } from '@/store/mediaViewerStore';
import { sanitizeMediaEdits } from '@/store/mediaViewerStore';
import { parseMessageDate } from '@/utils/chatTime';

export type ChatDataModel = {
  videoId?: number;
  senderId?: string;
  receiverId?: string;
  userName?: string;
  userAvatar?: string;
  tags?: string;
  myStatus?: string;
  otherStatus?: string;
  lastMessageType?: string;
  description?: string;
  messageData?: string;
  /** Expo preview overlays (text / filter / music) — ignored by Flutter. */
  messageEdits?: MediaEdits | null;
  avatar?: string;
  chatsId?: string;
  videoTime?: unknown;
  lastMessageTime?: unknown;
};

/** Matches Flutter `MessageType` enum `.name` values. */
export type ChatMessageType =
  | 'text'
  | 'image'
  | 'voice'
  | 'video'
  | 'document'
  | 'location'
  | 'file';

export type VoiceData = {
  url?: string;
  duration?: number;
  fileSize?: number;
  fileName?: string;
  fileExtension?: string;
  latitude?: number;
  longitude?: number;
  address?: string;
};

export type ChatMessage = {
  id: string;
  from?: string;
  to?: string;
  message?: string;
  files?: string[];
  timestamp?: unknown;
  status?: string;
  messageType?: ChatMessageType | string;
  voiceData?: VoiceData | null;
};

/** Flutter: concatenate largerId + smallerId + videoId */
export function buildChatRoomId(myId: number, secondUserId: number, videoId: number) {
  if (secondUserId > myId) {
    return `${secondUserId}${myId}${videoId}`;
  }
  return `${myId}${secondUserId}${videoId}`;
}

export async function getSingleChatDetail(
  myUserId: string,
  secondUserId: string,
  videoId: number,
): Promise<ChatDataModel | null> {
  const snap = await getDoc(
    doc(db, 'chatRooms', myUserId, myUserId, `${secondUserId}${videoId}`),
  );
  if (!snap.exists()) return null;
  return snap.data() as ChatDataModel;
}

/** Live updates for one chat room doc (accept / decline / status). */
export function listenSingleChatDetail(
  myUserId: string,
  secondUserId: string,
  videoId: number,
  onData: (room: ChatDataModel | null) => void,
  onError?: (error: Error) => void,
): Unsubscribe {
  return onSnapshot(
    doc(db, 'chatRooms', myUserId, myUserId, `${secondUserId}${videoId}`),
    (snap) => {
      onData(snap.exists() ? (snap.data() as ChatDataModel) : null);
    },
    (err) => onError?.(err),
  );
}

export async function uploadChatVideo(localUri: string, userId: string): Promise<string> {
  return uploadChatMedia(localUri, userId, 'video');
}

/** Upload video or image for chat reply (Flutter uploadToStorage). */
export async function uploadChatMedia(
  localUri: string,
  userId: string,
  kind: 'video' | 'image' = 'video',
): Promise<string> {
  const now = new Date();
  const today = `${now.getMonth() + 1}-${now.getDate()}`;
  const storageId = `${now.getTime()}${userId}`;
  const response = await fetch(localUri);
  const blob = await response.blob();
  const folder = kind === 'image' ? 'image' : 'video';
  const contentType =
    kind === 'image'
      ? blob.type || 'image/jpeg'
      : blob.type || 'video/mp4';
  const storageRef = ref(storage, `${folder}/${today}/${storageId}`);
  await uploadBytes(storageRef, blob, { contentType });
  return getDownloadURL(storageRef);
}

async function uploadBlobToPath(
  localUri: string,
  storagePath: string,
  contentType: string,
): Promise<{ url: string; fileSize: number }> {
  const blob = await readUriAsBlob(localUri);
  const storageRef = ref(storage, storagePath);
  await uploadBytes(storageRef, blob, {
    contentType: blob.type || contentType,
  });
  const url = await getDownloadURL(storageRef);
  return { url, fileSize: blob.size };
}

/** Flutter: `chats/{chatsId}/images/image_{ms}_{i}.jpg` */
export async function uploadChatImage(chatsId: string, localUri: string, index = 0) {
  const ms = Date.now();
  return uploadBlobToPath(
    localUri,
    `chats/${chatsId}/images/image_${ms}_${index}.jpg`,
    'image/jpeg',
  );
}

const DOC_MIME: Record<string, string> = {
  pdf: 'application/pdf',
  doc: 'application/msword',
  docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  xls: 'application/vnd.ms-excel',
  xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ppt: 'application/vnd.ms-powerpoint',
  pptx: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  txt: 'text/plain',
  zip: 'application/zip',
};

/** Flutter: `chats/{chatsId}/documents/doc_{ms}_{originalName}` */
export async function uploadChatDocument(
  chatsId: string,
  localUri: string,
  fileName: string,
  mimeType?: string,
) {
  const ms = Date.now();
  const safeName = fileName.replace(/[^\w.\-]+/g, '_');
  const ext = safeName.includes('.') ? safeName.split('.').pop()!.toLowerCase() : 'bin';
  const mime = mimeType || DOC_MIME[ext] || 'application/octet-stream';
  const result = await uploadBlobToPath(
    localUri,
    `chats/${chatsId}/documents/doc_${ms}_${safeName}`,
    mime,
  );
  return { ...result, fileName: safeName, fileExtension: ext };
}

/** Flutter: `chats/{chatsId}/videos/video_{ms}.mp4` */
export async function uploadInChatVideo(chatsId: string, localUri: string) {
  const ms = Date.now();
  return uploadBlobToPath(
    localUri,
    `chats/${chatsId}/videos/video_${ms}.mp4`,
    'video/mp4',
  );
}

/** Flutter: `chats/{chatsId}/voice_messages/voice_{ms}.m4a` */
export async function uploadChatVoice(chatsId: string, localUri: string) {
  const ms = Date.now();
  return uploadBlobToPath(
    localUri,
    `chats/${chatsId}/voice_messages/voice_${ms}.m4a`,
    'audio/mp4',
  );
}

export async function createChatRoom(params: {
  myUserId: string;
  myUsername?: string;
  myAvatar?: string;
  secondUserId: string;
  chatRoomId: string;
  userName: string;
  description: string;
  tags: string;
  videoUrl: string;
  userAvatar: string;
  videoId: number;
  messageEdits?: MediaEdits | null;
}) {
  const {
    myUserId,
    myUsername,
    myAvatar,
    secondUserId,
    chatRoomId,
    userName,
    description,
    tags,
    videoUrl,
    userAvatar,
    videoId,
    messageEdits = null,
  } = params;

  const payloadBase = {
    videoId,
    senderId: myUserId,
    receiverId: secondUserId,
    tags,
    description,
    lastMessageType: 'video',
    messageData: videoUrl,
    lastMessageTime: serverTimestamp(),
    videoTime: serverTimestamp(),
    chatsId: chatRoomId,
  };
  const cleanEdits = sanitizeMediaEdits(messageEdits);
  const payload = cleanEdits
    ? { ...payloadBase, messageEdits: cleanEdits }
    : payloadBase;

  await setDoc(doc(db, 'chatRooms', myUserId, myUserId, `${secondUserId}${videoId}`), {
    ...payload,
    userName,
    myStatus: 'Accepted',
    otherStatus: 'Pending',
    avatar: userAvatar,
  });

  await setDoc(doc(db, 'chatRooms', secondUserId, secondUserId, `${myUserId}${videoId}`), {
    ...payload,
    userName: myUsername ?? '',
    myStatus: 'Pending',
    otherStatus: 'Accepted',
    avatar: myAvatar ?? '',
  });
}

export async function updateChatRoom(params: {
  myUserId: string;
  secondUserId: string;
  videoId: number;
}) {
  const { myUserId, secondUserId, videoId } = params;
  const stamp = { lastMessageTime: serverTimestamp() };
  await updateDoc(doc(db, 'chatRooms', myUserId, myUserId, `${secondUserId}${videoId}`), stamp);
  await updateDoc(doc(db, 'chatRooms', secondUserId, secondUserId, `${myUserId}${videoId}`), stamp);
}

export async function updateAcceptanceStatus(params: {
  myUserId: string;
  secondUserId: string;
  videoId: number;
  status: 'Accepted' | 'Rejected';
}) {
  const { myUserId, secondUserId, videoId, status } = params;
  await updateDoc(doc(db, 'chatRooms', secondUserId, secondUserId, `${myUserId}${videoId}`), {
    otherStatus: status,
  });
  await updateDoc(doc(db, 'chatRooms', myUserId, myUserId, `${secondUserId}${videoId}`), {
    myStatus: status,
  });
}

/** Generic send — mirrors Flutter `Database.sendMessage` field keys. */
export async function sendChatMessage(params: {
  chatRoomId: string;
  from: string;
  to: string;
  videoId: number;
  message: string;
  messageType: ChatMessageType;
  files?: string[];
  voiceData?: VoiceData | null;
}) {
  const {
    chatRoomId,
    from,
    to,
    videoId,
    message,
    messageType,
    files = [],
    voiceData = null,
  } = params;

  await addDoc(collection(db, 'chatsData', chatRoomId, chatRoomId), {
    from,
    to,
    message,
    files,
    timestamp: serverTimestamp(),
    status: 'Active',
    messageType,
    voiceData,
  });
  await updateChatRoom({
    myUserId: from,
    secondUserId: to,
    videoId,
  });
}

export async function sendTextMessage(params: {
  chatRoomId: string;
  from: string;
  to: string;
  message: string;
  videoId: number;
}) {
  return sendChatMessage({
    ...params,
    messageType: 'text',
    files: [],
    voiceData: null,
  });
}

export function listenMessages(
  chatRoomId: string,
  onData: (messages: ChatMessage[]) => void,
  onError?: (error: Error) => void,
): Unsubscribe {
  const q = query(
    collection(db, 'chatsData', chatRoomId, chatRoomId),
    orderBy('timestamp', 'desc'),
  );
  return onSnapshot(
    q,
    (snap) => {
      onData(
        snap.docs.map((d) => ({
          id: d.id,
          ...(d.data() as Omit<ChatMessage, 'id'>),
        })),
      );
    },
    (err) => onError?.(err),
  );
}

/** Flutter getChats: selected 0 = My Replies (I am sender), 1 = My videos (I am receiver) */
export function listenChatRooms(
  myUserId: string,
  selected: 0 | 1,
  onData: (rooms: ChatDataModel[]) => void,
  onError?: (error: Error) => void,
): Unsubscribe {
  const field = selected === 0 ? 'senderId' : 'receiverId';
  const q = query(
    collection(db, 'chatRooms', myUserId, myUserId),
    where(field, '==', myUserId),
  );
  return onSnapshot(
    q,
    (snap) => {
      const rooms = snap.docs.map((d) => d.data() as ChatDataModel);
      rooms.sort((a, b) => {
        const ta = parseMessageDate(a.lastMessageTime)?.getTime() ?? 0;
        const tb = parseMessageDate(b.lastMessageTime)?.getTime() ?? 0;
        return tb - ta; // latest first
      });
      onData(rooms);
    },
    (err) => onError?.(err),
  );
}

/** All chat rooms for the signed-in user (both “My Replies” and “My videos”). */
export function listenAllChatRooms(
  myUserId: string,
  onData: (rooms: ChatDataModel[]) => void,
  onError?: (error: Error) => void,
): Unsubscribe {
  return onSnapshot(
    collection(db, 'chatRooms', myUserId, myUserId),
    (snap) => {
      const rooms = snap.docs.map((d) => d.data() as ChatDataModel);
      rooms.sort((a, b) => {
        const ta = parseMessageDate(a.lastMessageTime)?.getTime() ?? 0;
        const tb = parseMessageDate(b.lastMessageTime)?.getTime() ?? 0;
        return tb - ta;
      });
      onData(rooms);
    },
    (err) => onError?.(err),
  );
}

/** Flutter `Database.getRequestOnVideos` — rooms for a video where I am receiver. */
export function listenVideoFollowRequests(
  myUserId: string,
  videoId: number,
  onData: (rooms: ChatDataModel[]) => void,
  onError?: (error: Error) => void,
): Unsubscribe {
  // Query by receiver only (avoids composite-index failures), then filter videoId
  // client-side so number/string Firestore values both match.
  const q = query(
    collection(db, 'chatRooms', myUserId, myUserId),
    where('receiverId', '==', myUserId),
  );
  return onSnapshot(
    q,
    (snap) => {
      const target = Number(videoId);
      const rooms = snap.docs
        .map((d) => d.data() as ChatDataModel)
        .filter((r) => Number(r.videoId) === target)
        .sort((a, b) => {
          const ta = parseMessageDate(a.lastMessageTime)?.getTime() ?? 0;
          const tb = parseMessageDate(b.lastMessageTime)?.getTime() ?? 0;
          return tb - ta;
        });
      onData(rooms);
    },
    (err) => onError?.(err),
  );
}


