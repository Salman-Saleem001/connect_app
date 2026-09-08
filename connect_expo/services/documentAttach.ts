/**
 * Chat document attach — PDF, Word (.doc/.docx), Excel (.xls/.xlsx).
 * Mirrors Flutter ChatDetailController pick + upload + sendMessage fields.
 */
import { sendChatMessage, uploadChatDocument } from '@/services/chat';
import * as DocumentPicker from 'expo-document-picker';
import { Alert } from 'react-native';

const MAX_BYTES = 25 * 1024 * 1024;

/** Allowed office docs (Flutter parity + pdf). */
export const DOC_EXTENSIONS = ['pdf', 'doc', 'docx', 'xls', 'xlsx'] as const;

type DocExt = (typeof DOC_EXTENSIONS)[number];

const MIME_BY_EXT: Record<DocExt, string> = {
  pdf: 'application/pdf',
  doc: 'application/msword',
  docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  xls: 'application/vnd.ms-excel',
  xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
};

export type ChatAttachCtx = {
  chatsId: string;
  from: string;
  to: string;
  videoId: number;
};

export type PickedDocument = {
  uri: string;
  name: string;
  size: number;
  mimeType: string;
  extension: DocExt;
};

function extensionOf(name: string): string {
  const parts = name.trim().toLowerCase().split('.');
  return parts.length > 1 ? (parts.pop() ?? '') : '';
}

function resolveExtension(name: string, mimeType?: string | null): DocExt | null {
  const fromName = extensionOf(name);
  if ((DOC_EXTENSIONS as readonly string[]).includes(fromName)) {
    return fromName as DocExt;
  }
  const mime = (mimeType ?? '').toLowerCase();
  if (mime.includes('pdf')) return 'pdf';
  if (mime.includes('wordprocessingml') || mime.includes('msword')) {
    return mime.includes('openxmlformats') || mime.includes('openxml')
      ? 'docx'
      : 'doc';
  }
  if (
    mime.includes('spreadsheetml') ||
    mime.includes('ms-excel') ||
    mime.includes('excel')
  ) {
    return mime.includes('openxmlformats') || mime.includes('openxml')
      ? 'xlsx'
      : 'xls';
  }
  return null;
}

/**
 * Opens the system file picker with all files selectable.
 * UTI or MIME filters often gray out PDFs and Office docs on iOS.
 * After pick we only accept PDF, Word, or Excel.
 */
export async function pickOfficeDocument(): Promise<PickedDocument | null> {
  const result = await DocumentPicker.getDocumentAsync({
    type: '*/*',
    copyToCacheDirectory: true,
    multiple: false,
  });

  if (result.canceled || !result.assets?.[0]) return null;

  const asset = result.assets[0];
  const name = asset.name?.trim() || 'document.pdf';
  const ext = resolveExtension(name, asset.mimeType);

  if (!ext) {
    Alert.alert(
      'Unsupported file',
      'Please choose a PDF, Word (.doc, .docx), or Excel (.xls, .xlsx) file.',
    );
    return null;
  }

  if ((asset.size ?? 0) > MAX_BYTES) {
    Alert.alert('', 'Document must be 25MB or smaller.');
    return null;
  }

  if (!asset.uri) {
    Alert.alert('', 'Could not access the selected document.');
    return null;
  }

  return {
    uri: asset.uri,
    name,
    size: asset.size ?? 0,
    mimeType: asset.mimeType || MIME_BY_EXT[ext],
    extension: ext,
  };
}

/** Upload to Firebase Storage + write Firestore chat message. */
export async function sendOfficeDocument(ctx: ChatAttachCtx, doc: PickedDocument) {
  const uploaded = await uploadChatDocument(ctx.chatsId, doc.uri, doc.name, doc.mimeType);
  await sendChatMessage({
    chatRoomId: ctx.chatsId,
    from: ctx.from,
    to: ctx.to,
    videoId: ctx.videoId,
    message: doc.name,
    messageType: 'document',
    files: [],
    voiceData: {
      url: uploaded.url,
      fileName: doc.name,
      fileSize: uploaded.fileSize,
      fileExtension: uploaded.fileExtension || doc.extension,
    },
  });
}

export async function pickAndSendOfficeDocument(ctx: ChatAttachCtx): Promise<boolean> {
  const doc = await pickOfficeDocument();
  if (!doc) return false;
  await sendOfficeDocument(ctx, doc);
  return true;
}
