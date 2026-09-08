import type { MediaEdits } from '@/store/mediaViewerStore';
import { sanitizeMediaEdits } from '@/store/mediaViewerStore';
import { create } from 'zustand';

export type PostLocation = {
  lat: number;
  lng: number;
  city: string;
  state: string;
  country: string;
  label: string;
};

type PostDraftState = {
  location: PostLocation | null;
  /** Video text/filter overlays from preview (not baked into file). */
  mediaEdits: MediaEdits | null;
  setLocation: (loc: PostLocation) => void;
  clearLocation: () => void;
  setMediaEdits: (edits: MediaEdits | null) => void;
  clear: () => void;
};

export const usePostDraftStore = create<PostDraftState>((set) => ({
  location: null,
  mediaEdits: null,
  setLocation: (location) => set({ location }),
  clearLocation: () => set({ location: null }),
  setMediaEdits: (edits) => set({ mediaEdits: sanitizeMediaEdits(edits) }),
  clear: () => set({ location: null, mediaEdits: null }),
}));
