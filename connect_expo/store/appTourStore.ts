import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';

/**
 * Flutter key — once true, TakeTour never shows again.
 * We set this after the first post-login offer (Continue, close, Skip, or Done)
 * so the tour is first-install / first-login only.
 */
const TOUR_SKIP_KEY = 'hasUserCanceledAppOverView';

export type TourPlacement = 'top' | 'bottom' | 'left' | 'right';

export type TourStepId =
  | 'like'
  | 'connect'
  | 'share'
  | 'more'
  | 'feedTab'
  | 'trendingTab'
  | 'recommendedTab'
  | 'homeTab'
  | 'searchTab'
  | 'createVideo'
  | 'chatTab'
  | 'profileTab';

export type TourStep = {
  id: TourStepId;
  title: string;
  description: string;
  placement: TourPlacement;
};

/** Same order + copy as Flutter `home_page.dart` / `bottom_bar_screen.dart` / `take_tour.dart`. */
export const TOUR_STEPS: TourStep[] = [
  {
    id: 'like',
    title: 'Like Button',
    description: 'Hit the Like button to like the video',
    placement: 'right',
  },
  {
    id: 'connect',
    title: 'Connect with Friends',
    description:
      ' Connect with friends by sharing the video and getting feedback',
    placement: 'right',
  },
  {
    id: 'share',
    title: 'Share with others',
    description: 'Share the video outside the app with others and get feedback',
    placement: 'right',
  },
  {
    id: 'more',
    title: 'More Options',
    description: 'Report inappropriate content or block users',
    placement: 'right',
  },
  {
    id: 'feedTab',
    title: 'Your Personal Feed',
    description: 'View content tailored to your interests and connections',
    placement: 'bottom',
  },
  {
    id: 'trendingTab',
    title: 'Explore Trending Content',
    description: 'Discover the most popular and trending videos right now',
    placement: 'bottom',
  },
  {
    id: 'recommendedTab',
    title: 'Explore Recommended Content',
    description:
      'Discover personalized content recommendations based on your interests',
    placement: 'bottom',
  },
  {
    id: 'homeTab',
    title: 'Home Feed',
    description:
      'Navigate to your personalized home feed with trending and recommended content',
    placement: 'top',
  },
  {
    id: 'searchTab',
    title: 'Search',
    description:
      'Explore and discover content based on your interests and preferences',
    placement: 'top',
  },
  {
    id: 'createVideo',
    title: 'Create Your Video',
    description: 'Tap to start recording and sharing your content',
    placement: 'top',
  },
  {
    id: 'chatTab',
    title: 'Chats',
    description:
      'Connect and communicate with other users through direct messages',
    placement: 'top',
  },
  {
    id: 'profileTab',
    title: 'Profile',
    description: 'View and manage your profile, posts, and personal information',
    placement: 'top',
  },
];

export type TargetRect = {
  x: number;
  y: number;
  width: number;
  height: number;
};

type AppTourState = {
  hydrated: boolean;
  /** True after first tour offer — never prompt again on this install. */
  skippedForever: boolean;
  welcomeVisible: boolean;
  running: boolean;
  stepIndex: number;
  remeasureEpoch: number;
  targets: Partial<Record<TourStepId, TargetRect>>;
  frozenTargets: Partial<Record<TourStepId, TargetRect>> | null;
  hydrate: () => Promise<void>;
  /** Persist that the first-time tour has been offered / finished. */
  markTourSeen: () => Promise<void>;
  setSkippedForever: (value: boolean) => Promise<void>;
  showWelcome: () => void;
  hideWelcome: () => void;
  startTour: () => void;
  next: () => void;
  skip: () => void;
  registerTarget: (id: TourStepId, rect: TargetRect | null) => void;
  bumpRemeasure: () => void;
  /** Show welcome once after first login if never seen on this install. */
  maybePrompt: () => void;
};

async function persistSeen() {
  await AsyncStorage.setItem(TOUR_SKIP_KEY, 'true');
}

export const useAppTourStore = create<AppTourState>((set, get) => ({
  hydrated: false,
  skippedForever: false,
  welcomeVisible: false,
  running: false,
  stepIndex: 0,
  remeasureEpoch: 0,
  targets: {},
  frozenTargets: null,

  hydrate: async () => {
    try {
      const raw = await AsyncStorage.getItem(TOUR_SKIP_KEY);
      set({
        skippedForever: raw === 'true',
        hydrated: true,
      });
    } catch {
      set({ hydrated: true });
    }
  },

  markTourSeen: async () => {
    await persistSeen();
    set({ skippedForever: true });
  },

  setSkippedForever: async (value) => {
    await AsyncStorage.setItem(TOUR_SKIP_KEY, value ? 'true' : 'false');
    set({ skippedForever: value });
  },

  showWelcome: () => {
    if (get().skippedForever || get().running) return;
    set({ welcomeVisible: true });
  },

  hideWelcome: () => set({ welcomeVisible: false }),

  startTour: () => {
    const snapshot = { ...get().targets };
    set({
      welcomeVisible: false,
      running: true,
      stepIndex: 0,
      frozenTargets: snapshot,
    });
    // First-time only — do not offer again on next launch
    void get().markTourSeen();
  },

  next: () => {
    const { stepIndex } = get();
    if (stepIndex >= TOUR_STEPS.length - 1) {
      set({ running: false, stepIndex: 0, frozenTargets: null });
      void get().markTourSeen();
      return;
    }
    set({ stepIndex: stepIndex + 1 });
  },

  skip: () => {
    set({ running: false, stepIndex: 0, frozenTargets: null });
    void get().markTourSeen();
  },

  bumpRemeasure: () => {
    set({ remeasureEpoch: get().remeasureEpoch + 1 });
  },

  registerTarget: (id, rect) => {
    if (get().running) return;
    set((s) => {
      if (!rect) {
        if (!s.targets[id]) return s;
        const next = { ...s.targets };
        delete next[id];
        return { targets: next };
      }
      const prev = s.targets[id];
      if (
        prev &&
        Math.abs(prev.x - rect.x) < 1 &&
        Math.abs(prev.y - rect.y) < 1 &&
        Math.abs(prev.width - rect.width) < 1 &&
        Math.abs(prev.height - rect.height) < 1
      ) {
        return s;
      }
      return { targets: { ...s.targets, [id]: rect } };
    });
  },

  maybePrompt: () => {
    const { hydrated, skippedForever, running, welcomeVisible } = get();
    // Only the first time after install + login
    if (!hydrated || skippedForever || running || welcomeVisible) return;
    set({ welcomeVisible: true });
  },
}));
