import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';

/** Overlay edits applied in media preview (Expo Go — not baked into video file). */
export type MediaEdits = {
  text?: string;
  textColor?: string;
  fontSize?: number;
  bold?: boolean;
  /** 0–1 relative to preview width/height */
  xNorm?: number;
  yNorm?: number;
  filterColor?: string | null;
  audioId?: 'distant' | 'stock' | 'sunlit' | string | null;
};

const OVERLAY_KEY = 'mediaOverlaysByUrl';

/** Strip `undefined` so Firestore accepts the object. */
export function sanitizeMediaEdits(edits: MediaEdits | null | undefined): MediaEdits | null {
  if (!edits) return null;
  const out: MediaEdits = {};
  if (edits.text != null && String(edits.text).trim()) out.text = String(edits.text).trim();
  if (edits.textColor != null) out.textColor = edits.textColor;
  if (edits.fontSize != null) out.fontSize = edits.fontSize;
  if (edits.bold != null) out.bold = edits.bold;
  if (edits.xNorm != null && Number.isFinite(edits.xNorm)) out.xNorm = edits.xNorm;
  if (edits.yNorm != null && Number.isFinite(edits.yNorm)) out.yNorm = edits.yNorm;
  if (edits.filterColor != null) out.filterColor = edits.filterColor;
  if (edits.audioId != null) out.audioId = edits.audioId;
  return Object.keys(out).length ? out : null;
}

/** Hidden marker in post `info` so feed can restore video overlays (API has no edits field). */
const CG_EDITS_MARKER = '[[cg_edits]]';

export function appendMediaEditsToInfo(
  info: string,
  edits: MediaEdits | null | undefined,
): string {
  const clean = sanitizeMediaEdits(edits);
  const base = stripMediaEditsFromInfo(info).info;
  if (!clean) return base;
  return `${base}${base ? '\n' : ''}${CG_EDITS_MARKER}${JSON.stringify(clean)}`;
}

export function stripMediaEditsFromInfo(info?: string | null): {
  info: string;
  edits: MediaEdits | null;
} {
  const raw = info ?? '';
  const idx = raw.indexOf(CG_EDITS_MARKER);
  if (idx < 0) return { info: raw, edits: null };
  const base = raw.slice(0, idx).replace(/\s+$/, '');
  try {
    const parsed = JSON.parse(raw.slice(idx + CG_EDITS_MARKER.length)) as MediaEdits;
    return { info: base, edits: sanitizeMediaEdits(parsed) };
  } catch {
    return { info: base, edits: null };
  }
}

type MediaViewerState = {
  url: string | null;
  isImage: boolean;
  edits: MediaEdits | null;
  setMedia: (
    url: string,
    opts?: { isImage?: boolean; edits?: MediaEdits | null },
  ) => void;
  clear: () => void;
};

export const useMediaViewerStore = create<MediaViewerState>((set) => ({
  url: null,
  isImage: false,
  edits: null,
  setMedia: (url, opts) =>
    set({
      url,
      isImage: !!opts?.isImage,
      edits: sanitizeMediaEdits(opts?.edits ?? null),
    }),
  clear: () => set({ url: null, isImage: false, edits: null }),
}));

export function openChatMedia(
  url: string,
  opts?: { isImage?: boolean; edits?: MediaEdits | null },
) {
  const fromArg = sanitizeMediaEdits(opts?.edits ?? null);
  const fromCache = useMediaOverlayStore.getState().get(url);
  useMediaViewerStore.getState().setMedia(url, {
    isImage: opts?.isImage,
    edits: fromArg ?? fromCache,
  });
}

type OverlayMapState = {
  byUrl: Record<string, MediaEdits>;
  hydrated: boolean;
  hydrate: () => Promise<void>;
  remember: (url: string, edits: MediaEdits | null) => void;
  get: (url?: string | null) => MediaEdits | null;
};

async function persistMap(byUrl: Record<string, MediaEdits>) {
  try {
    await AsyncStorage.setItem(OVERLAY_KEY, JSON.stringify(byUrl));
  } catch {
    // ignore
  }
}

/** Local cache of video overlays (feed/chat) keyed by media URL — Expo Go can't burn text into video. */
export const useMediaOverlayStore = create<OverlayMapState>((set, get) => ({
  byUrl: {},
  hydrated: false,
  hydrate: async () => {
    try {
      const raw = await AsyncStorage.getItem(OVERLAY_KEY);
      if (raw) {
        const parsed = JSON.parse(raw) as Record<string, MediaEdits>;
        set({ byUrl: parsed ?? {}, hydrated: true });
        return;
      }
    } catch {
      // ignore
    }
    set({ hydrated: true });
  },
  remember: (url, edits) => {
    const clean = sanitizeMediaEdits(edits);
    const key = url.trim();
    if (!key || !clean) return;
    const byUrl = { ...get().byUrl, [key]: clean };
    set({ byUrl });
    void persistMap(byUrl);
  },
  get: (url) => {
    if (!url) return null;
    return get().byUrl[url.trim()] ?? null;
  },
}));
