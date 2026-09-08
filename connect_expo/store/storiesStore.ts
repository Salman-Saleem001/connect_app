import { create } from 'zustand';

import type { StoriesPayload, StoryItem } from '@/types/stories';

type StoriesState = {
  payload: StoriesPayload;
  loading: boolean;
  /** Instagram-style ring while a new story is uploading. */
  uploading: boolean;
  uploadProgress: number;
  uploadPreviewUri: string | null;
  /** Status viewer queue (avoid putting media URLs in router params). */
  viewerStatuses: StoryItem[];
  viewerIndex: number;
  setPayload: (payload: StoriesPayload) => void;
  setLoading: (loading: boolean) => void;
  beginUpload: (previewUri?: string | null) => void;
  setUploadProgress: (progress: number) => void;
  finishUpload: () => void;
  markViewed: (storyId: number, isSelf: boolean) => void;
  openViewer: (statuses: StoryItem[], initialIndex?: number) => void;
  clearViewer: () => void;
};

export const useStoriesStore = create<StoriesState>((set) => ({
  payload: { my_stories: [], feed: [] },
  loading: false,
  uploading: false,
  uploadProgress: 0,
  uploadPreviewUri: null,
  viewerStatuses: [],
  viewerIndex: 0,
  setPayload: (payload) => set({ payload }),
  setLoading: (loading) => set({ loading }),
  beginUpload: (previewUri = null) =>
    set({
      uploading: true,
      uploadProgress: 0.02,
      uploadPreviewUri: previewUri,
    }),
  setUploadProgress: (progress) =>
    set({
      uploadProgress: Math.max(0.02, Math.min(1, progress)),
    }),
  finishUpload: () =>
    set({
      uploading: false,
      uploadProgress: 0,
      uploadPreviewUri: null,
    }),
  markViewed: (storyId, isSelf) =>
    set((s) => {
      const key = isSelf ? 'my_stories' : 'feed';
      const list = s.payload[key].map((item) =>
        item.id === storyId ? { ...item, is_viewed: true } : item,
      );
      return { payload: { ...s.payload, [key]: list } };
    }),
  openViewer: (statuses, initialIndex = 0) =>
    set({
      viewerStatuses: statuses,
      viewerIndex: Math.max(0, Math.min(initialIndex, statuses.length - 1)),
    }),
  clearViewer: () => set({ viewerStatuses: [], viewerIndex: 0 }),
}));
