import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';

import { syncAppIconBadge } from '@/services/notifications';

export type ToastKind = 'info' | 'success' | 'warning' | 'error';

export type InAppToast = {
  id: string;
  title?: string;
  message: string;
  kind: ToastKind;
  createdAt: number;
  /** Inbox id — toast tap opens the matching notification. */
  inboxId?: string;
};

/** Deep-link target when tapping an inbox row. */
export type InboxRoute =
  | {
      type: 'chat';
      videoId: number | string;
      secondUserId: string;
      userName?: string;
      userAvatar?: string;
      chatsId?: string;
      senderId?: string;
      receiverId?: string;
      myStatus?: string;
      otherStatus?: string;
      messageData?: string;
      description?: string;
      tags?: string;
      bio?: string;
    }
  | {
      type: 'followRequests';
      videoId: number | string;
      thumbnail?: string;
      name?: string;
      viewsCount?: number | string;
    }
  | { type: 'chats'; tab?: 0 | 1 }
  | { type: 'home' }
  | { type: 'profile' };

export type InboxItem = {
  id: string;
  /** Owner — only this logged-in user should see it. */
  userId: string;
  title: string;
  message: string;
  kind: ToastKind;
  createdAt: number;
  read: boolean;
  /** Tie to a chat room so opening chat marks this read. */
  roomKey?: string;
  avatar?: string;
  route?: InboxRoute;
};

/** Legacy global keys (pre user-scoped) — cleared so old shared junk does not reappear. */
const LEGACY_INBOX_KEY = 'notificationInbox';
const LEGACY_UNREAD_KEY = 'notificationUnreadKeys';
const ENABLED_KEY = 'notificationStatus';
const MAX_INBOX = 100;

function inboxStorageKey(userId: string) {
  return `notificationInbox_u_${userId}`;
}
function unreadStorageKey(userId: string) {
  return `notificationUnreadKeys_u_${userId}`;
}
function alertsStorageKey(userId: string) {
  return `notificationAlerts_u_${userId}`;
}

type AlertsBlob = {
  pending: Record<string, true>;
  activity: Record<string, number>;
  status: Record<string, string>;
};

type NotificationState = {
  enabled: boolean;
  hydrated: boolean;
  /** Logged-in user whose inbox is loaded. */
  userId: string | null;
  /** Unread inbox count — shown on app icon + tab + bell. */
  badgeCount: number;
  toasts: InAppToast[];
  inbox: InboxItem[];
  alertedPending: Record<string, true>;
  alertedActivity: Record<string, number>;
  alertedStatus: Record<string, string>;
  unreadKeys: Record<string, true>;
  activeChatRoomId: string | null;
  hydrate: () => Promise<void>;
  /** Load / switch inbox for this user (call on login / session restore / logout). */
  bindUser: (userId: string | null) => Promise<void>;
  setEnabled: (value: boolean) => Promise<void>;
  setActiveChatRoomId: (id: string | null) => void;
  showToast: (opts: {
    message: string;
    title?: string;
    kind?: ToastKind;
    inboxId?: string;
  }) => void;
  dismissToast: (id: string) => void;
  pushInbox: (item: Omit<InboxItem, 'id' | 'createdAt' | 'read' | 'userId'> & {
    id?: string;
    createdAt?: number;
    read?: boolean;
    userId?: string;
    /** Also show floating toast (default true). */
    toast?: boolean;
  }) => string;
  markInboxRead: (id: string) => void;
  markInboxReadByRoomKey: (roomKey: string) => void;
  markAllInboxRead: () => void;
  clearInbox: () => void;
  markRoomSeen: (roomKey: string) => void;
  addUnread: (roomKey: string) => void;
  setUnreadKeys: (keys: Record<string, true>) => void;
  notePendingAlerted: (roomKey: string) => void;
  noteActivityAlerted: (roomKey: string, at: number) => void;
  noteStatusAlerted: (roomKey: string, status: string) => void;
  /** Seed alert maps from current rooms without notifying (first snapshot after reload). */
  seedAlerts: (data: {
    pending?: Record<string, true>;
    activity?: Record<string, number>;
    status?: Record<string, string>;
  }) => void;
  clearAllBadges: () => void;
  refreshAppIconBadge: () => void;
};

function persistUnread(userId: string | null, unreadKeys: Record<string, true>) {
  if (!userId) return;
  void AsyncStorage.setItem(unreadStorageKey(userId), JSON.stringify(unreadKeys));
}

function persistInbox(userId: string | null, inbox: InboxItem[]) {
  if (!userId) return;
  void AsyncStorage.setItem(inboxStorageKey(userId), JSON.stringify(inbox));
}

function persistAlerts(
  userId: string | null,
  pending: Record<string, true>,
  activity: Record<string, number>,
  status: Record<string, string>,
) {
  if (!userId) return;
  const blob: AlertsBlob = { pending, activity, status };
  void AsyncStorage.setItem(alertsStorageKey(userId), JSON.stringify(blob));
}

function unreadInboxCount(inbox: InboxItem[]) {
  return inbox.filter((i) => !i.read).length;
}

function applyBadge(enabled: boolean, count: number) {
  void syncAppIconBadge(enabled ? count : 0);
}

function syncBadge(
  get: () => NotificationState,
  set: (p: Partial<NotificationState>) => void,
) {
  const { enabled, inbox, unreadKeys } = get();
  const fromInbox = unreadInboxCount(inbox);
  const fromRooms = Object.keys(unreadKeys).length;
  const badgeCount = Math.max(fromInbox, fromRooms);
  set({ badgeCount });
  applyBadge(enabled, badgeCount);
}

function emptyAlerts(): AlertsBlob {
  return { pending: {}, activity: {}, status: {} };
}

export const useNotificationStore = create<NotificationState>((set, get) => ({
  enabled: true,
  hydrated: false,
  userId: null,
  badgeCount: 0,
  toasts: [],
  inbox: [],
  alertedPending: {},
  alertedActivity: {},
  alertedStatus: {},
  unreadKeys: {},
  activeChatRoomId: null,

  hydrate: async () => {
    try {
      const enabledRaw = await AsyncStorage.getItem(ENABLED_KEY);
      const enabled = enabledRaw == null ? true : enabledRaw === 'true';
      // Drop legacy device-wide inbox so old shared notifications never come back
      await AsyncStorage.multiRemove([LEGACY_INBOX_KEY, LEGACY_UNREAD_KEY]);
      set({ enabled, hydrated: true });
      applyBadge(enabled, 0);
    } catch {
      set({ hydrated: true });
    }
  },

  bindUser: async (userId) => {
    const prev = get().userId;
    const nextId = userId?.trim() ? String(userId).trim() : null;

    if (prev === nextId && get().hydrated) {
      // Already bound — still refresh badge
      syncBadge(get, set);
      return;
    }

    // Persist previous user's in-memory alerts before switching
    if (prev) {
      const s = get();
      persistAlerts(prev, s.alertedPending, s.alertedActivity, s.alertedStatus);
      persistInbox(prev, s.inbox);
      persistUnread(prev, s.unreadKeys);
    }

    if (!nextId) {
      set({
        userId: null,
        inbox: [],
        unreadKeys: {},
        alertedPending: {},
        alertedActivity: {},
        alertedStatus: {},
        toasts: [],
        badgeCount: 0,
        activeChatRoomId: null,
      });
      applyBadge(get().enabled, 0);
      return;
    }

    try {
      const [inboxRaw, unreadRaw, alertsRaw] = await Promise.all([
        AsyncStorage.getItem(inboxStorageKey(nextId)),
        AsyncStorage.getItem(unreadStorageKey(nextId)),
        AsyncStorage.getItem(alertsStorageKey(nextId)),
      ]);

      let inbox: InboxItem[] = [];
      if (inboxRaw) {
        try {
          const parsed = JSON.parse(inboxRaw) as InboxItem[];
          if (Array.isArray(parsed)) {
            inbox = parsed.filter(
              (i) => i && (i.userId == null || String(i.userId) === nextId),
            );
            inbox = inbox.map((i) => ({ ...i, userId: nextId }));
          }
        } catch {
          inbox = [];
        }
      }

      let unreadKeys: Record<string, true> = {};
      if (unreadRaw) {
        try {
          unreadKeys = JSON.parse(unreadRaw) as Record<string, true>;
        } catch {
          unreadKeys = {};
        }
      }

      let alerts = emptyAlerts();
      if (alertsRaw) {
        try {
          const parsed = JSON.parse(alertsRaw) as AlertsBlob;
          alerts = {
            pending: parsed.pending ?? {},
            activity: parsed.activity ?? {},
            status: parsed.status ?? {},
          };
        } catch {
          alerts = emptyAlerts();
        }
      }

      const badgeCount = Math.max(
        unreadInboxCount(inbox),
        Object.keys(unreadKeys).length,
      );

      set({
        userId: nextId,
        inbox,
        unreadKeys,
        alertedPending: alerts.pending,
        alertedActivity: alerts.activity,
        alertedStatus: alerts.status,
        toasts: [],
        badgeCount,
        activeChatRoomId: null,
      });
      applyBadge(get().enabled, badgeCount);
    } catch {
      set({
        userId: nextId,
        inbox: [],
        unreadKeys: {},
        alertedPending: {},
        alertedActivity: {},
        alertedStatus: {},
        toasts: [],
        badgeCount: 0,
      });
    }
  },

  setEnabled: async (value) => {
    await AsyncStorage.setItem(ENABLED_KEY, value ? 'true' : 'false');
    set({ enabled: value });
    syncBadge(get, set);
  },

  setActiveChatRoomId: (id) => set({ activeChatRoomId: id }),

  showToast: ({ message, title, kind = 'info', inboxId }) => {
    if (!get().enabled) return;
    const msg = message.trim();
    if (!msg) return;
    const id = `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    const toast: InAppToast = {
      id,
      title,
      message: msg,
      kind,
      createdAt: Date.now(),
      inboxId,
    };
    set((s) => ({ toasts: [...s.toasts.slice(-4), toast] }));
    setTimeout(() => {
      get().dismissToast(id);
    }, 4000);
  },

  dismissToast: (id) =>
    set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) })),

  pushInbox: (item) => {
    const userId = item.userId ?? get().userId;
    const id =
      item.id ?? `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    if (!get().enabled || !userId) return id;

    const entry: InboxItem = {
      id,
      userId,
      title: item.title,
      message: item.message,
      kind: item.kind ?? 'info',
      createdAt: item.createdAt ?? Date.now(),
      read: item.read ?? false,
      roomKey: item.roomKey,
      avatar: item.avatar,
      route: item.route,
    };

    set((s) => {
      // Dedupe: same room + same title for this user → replace, don't stack
      const filtered = s.inbox.filter((existing) => {
        if (existing.userId !== userId) return false;
        if (entry.roomKey && existing.roomKey === entry.roomKey) {
          if (existing.title === entry.title) return false;
        }
        return true;
      });
      const inbox = [entry, ...filtered].slice(0, MAX_INBOX);
      persistInbox(userId, inbox);
      return { inbox };
    });

    syncBadge(get, set);

    if (item.toast !== false) {
      get().showToast({
        message: entry.message,
        title: entry.title,
        kind: entry.kind,
        inboxId: entry.id,
      });
    }
    return id;
  },

  markInboxRead: (id) => {
    const userId = get().userId;
    set((s) => {
      const inbox = s.inbox.map((i) => (i.id === id ? { ...i, read: true } : i));
      persistInbox(userId, inbox);
      return { inbox };
    });
    syncBadge(get, set);
  },

  markInboxReadByRoomKey: (roomKey) => {
    const key = roomKey.trim();
    if (!key) return;
    const userId = get().userId;
    set((s) => {
      const inbox = s.inbox.map((i) =>
        i.roomKey === key ? { ...i, read: true } : i,
      );
      persistInbox(userId, inbox);
      return { inbox };
    });
    syncBadge(get, set);
  },

  markAllInboxRead: () => {
    const userId = get().userId;
    set((s) => {
      const inbox = s.inbox.map((i) => ({ ...i, read: true }));
      persistInbox(userId, inbox);
      return { inbox };
    });
    get().clearAllBadges();
  },

  clearInbox: () => {
    const userId = get().userId;
    set({ inbox: [] });
    persistInbox(userId, []);
    syncBadge(get, set);
  },

  markRoomSeen: (roomKey) => {
    const key = roomKey.trim();
    if (!key) return;
    const unreadKeys = { ...get().unreadKeys };
    delete unreadKeys[key];
    set({ unreadKeys });
    persistUnread(get().userId, unreadKeys);
    get().markInboxReadByRoomKey(key);
    syncBadge(get, set);
  },

  addUnread: (roomKey) => {
    const key = roomKey.trim();
    if (!key) return;
    if (!get().unreadKeys[key]) {
      const unreadKeys = { ...get().unreadKeys, [key]: true as const };
      set({ unreadKeys });
      persistUnread(get().userId, unreadKeys);
    }
    syncBadge(get, set);
  },

  setUnreadKeys: (keys) => {
    set({ unreadKeys: keys });
    persistUnread(get().userId, keys);
    syncBadge(get, set);
  },

  notePendingAlerted: (roomKey) => {
    set((s) => {
      const alertedPending = { ...s.alertedPending, [roomKey]: true };
      persistAlerts(s.userId, alertedPending, s.alertedActivity, s.alertedStatus);
      return { alertedPending };
    });
  },

  noteActivityAlerted: (roomKey, at) => {
    set((s) => {
      const alertedActivity = { ...s.alertedActivity, [roomKey]: at };
      persistAlerts(s.userId, s.alertedPending, alertedActivity, s.alertedStatus);
      return { alertedActivity };
    });
  },

  noteStatusAlerted: (roomKey, status) => {
    set((s) => {
      const alertedStatus = { ...s.alertedStatus, [roomKey]: status };
      persistAlerts(s.userId, s.alertedPending, s.alertedActivity, alertedStatus);
      return { alertedStatus };
    });
  },

  seedAlerts: ({ pending, activity, status }) => {
    set((s) => {
      const alertedPending = { ...s.alertedPending, ...(pending ?? {}) };
      const alertedActivity = { ...s.alertedActivity, ...(activity ?? {}) };
      const alertedStatus = { ...s.alertedStatus, ...(status ?? {}) };
      persistAlerts(s.userId, alertedPending, alertedActivity, alertedStatus);
      return { alertedPending, alertedActivity, alertedStatus };
    });
  },

  clearAllBadges: () => {
    const userId = get().userId;
    set((s) => {
      const inbox = s.inbox.map((i) => ({ ...i, read: true }));
      persistInbox(userId, inbox);
      persistUnread(userId, {});
      return { unreadKeys: {}, inbox, badgeCount: 0 };
    });
    applyBadge(true, 0);
  },

  refreshAppIconBadge: () => {
    syncBadge(get, set);
  },
}));

/** Fire toast + optional inbox entry (only for the bound user). */
export function notify(
  message: string,
  opts?: {
    title?: string;
    kind?: ToastKind;
    roomKey?: string;
    avatar?: string;
    route?: InboxRoute;
    /** Persist in notification center (default true when route provided, else false for trivial toasts). */
    inbox?: boolean;
    toast?: boolean;
  },
) {
  const store = useNotificationStore.getState();
  if (!store.userId) {
    // No logged-in user — toast only, never persist shared inbox
    if (opts?.toast !== false && store.enabled) {
      store.showToast({
        message,
        title: opts?.title,
        kind: opts?.kind ?? 'info',
      });
    }
    return;
  }

  const wantInbox = opts?.inbox ?? !!opts?.route;
  if (wantInbox) {
    store.pushInbox({
      title: opts?.title ?? 'Notification',
      message,
      kind: opts?.kind ?? 'info',
      roomKey: opts?.roomKey,
      avatar: opts?.avatar,
      route: opts?.route,
      toast: opts?.toast,
      userId: store.userId,
    });
    return;
  }
  store.showToast({
    message,
    title: opts?.title,
    kind: opts?.kind ?? 'info',
  });
}

export function roomNotificationKey(room: {
  chatsId?: string;
  senderId?: string;
  receiverId?: string;
  videoId?: number;
}) {
  return (
    room.chatsId ||
    `${room.senderId ?? ''}_${room.receiverId ?? ''}_${room.videoId ?? ''}`
  );
}

/** Navigate from an inbox / toast route payload. */
export function openInboxRoute(route: InboxRoute | undefined) {
  return route;
}
