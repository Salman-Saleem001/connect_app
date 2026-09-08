/**
 * Foreground watcher: connection requests, accept/decline, new chat activity.
 * Pushes inbox rows + toasts + app-icon badge — only for the logged-in user.
 *
 * First Firestore snapshot seeds alert state without notifying, so reload
 * does not re-fire the same connection/chat alerts.
 */
import { presentLocalNotification } from '@/services/notifications';
import { listenAllChatRooms, type ChatDataModel } from '@/services/chat';
import { useAuthStore } from '@/store/authStore';
import {
  notify,
  roomNotificationKey,
  useNotificationStore,
  type InboxRoute,
} from '@/store/notificationStore';
import { parseMessageDate } from '@/utils/chatTime';
import React, { useEffect, useRef } from 'react';
import { AppState, type AppStateStatus } from 'react-native';

function displayName(room: ChatDataModel) {
  return (room.userName || 'Someone').toString();
}

function chatRoute(room: ChatDataModel, myId: string): InboxRoute {
  const senderId = room.senderId ? String(room.senderId) : '';
  const receiverId = room.receiverId ? String(room.receiverId) : '';
  const secondUserId = senderId === myId ? receiverId : senderId;
  return {
    type: 'chat',
    videoId: room.videoId ?? 0,
    secondUserId,
    userName: room.userName ?? '',
    userAvatar: room.userAvatar || room.avatar || '',
    chatsId: room.chatsId ?? '',
    senderId,
    receiverId,
    myStatus: room.myStatus ?? '',
    otherStatus: room.otherStatus ?? '',
    messageData: room.messageData ?? '',
    description: room.description ?? '',
    tags: room.tags ?? '',
  };
}

export function AppNotificationWatcher() {
  const myId = useAuthStore((s) => (s.user?.id != null ? String(s.user.id) : ''));
  const enabled = useNotificationStore((s) => s.enabled);
  const hydrated = useNotificationStore((s) => s.hydrated);
  const boundUserId = useNotificationStore((s) => s.userId);
  const seededRef = useRef(false);

  useEffect(() => {
    const onChange = (state: AppStateStatus) => {
      if (state === 'active' || state === 'background') {
        useNotificationStore.getState().refreshAppIconBadge();
      }
    };
    const sub = AppState.addEventListener('change', onChange);
    useNotificationStore.getState().refreshAppIconBadge();
    return () => sub.remove();
  }, []);

  // Bind inbox storage to the logged-in user (user-specific notifications)
  useEffect(() => {
    if (!hydrated) return;
    void useNotificationStore.getState().bindUser(myId || null);
  }, [hydrated, myId]);

  useEffect(() => {
    seededRef.current = false;
    if (!myId || !hydrated || boundUserId !== myId) return;

    const unsub = listenAllChatRooms(myId, (rooms) => {
      const store = useNotificationStore.getState();
      if (store.userId !== myId) return;

      if (!store.enabled) {
        store.setUnreadKeys({});
        return;
      }

      // First snapshot after login/reload: remember current room states,
      // update unread badges, but do NOT toast / push inbox again.
      if (!seededRef.current) {
        seededRef.current = true;
        const pending: Record<string, true> = {};
        const activity: Record<string, number> = {};
        const status: Record<string, string> = {};
        const nextUnread: Record<string, true> = {};

        for (const room of rooms) {
          const key = roomNotificationKey(room);
          if (!key) continue;
          const isReceiver = String(room.receiverId ?? '') === myId;
          const isSender = String(room.senderId ?? '') === myId;
          const active = store.activeChatRoomId;
          const isActive =
            !!active && (active === room.chatsId || active === key);

          if (isReceiver && room.myStatus === 'Pending') {
            pending[key] = true;
            if (!isActive) nextUnread[key] = true;
          }
          if (
            isSender &&
            (room.otherStatus === 'Accepted' || room.otherStatus === 'Rejected')
          ) {
            status[key] = String(room.otherStatus);
          }
          const activityAt =
            parseMessageDate(room.lastMessageTime)?.getTime() ?? 0;
          if (activityAt > 0) {
            activity[key] = activityAt;
          }
        }

        store.seedAlerts({ pending, activity, status });
        store.setUnreadKeys(nextUnread);
        return;
      }

      const nextUnread: Record<string, true> = {};

      for (const room of rooms) {
        const key = roomNotificationKey(room);
        if (!key) continue;

        const active = store.activeChatRoomId;
        const isActive =
          !!active && (active === room.chatsId || active === key);
        const isReceiver = String(room.receiverId ?? '') === myId;
        const isSender = String(room.senderId ?? '') === myId;
        const avatar = room.userAvatar || room.avatar || undefined;
        const route = chatRoute(room, myId);

        if (isReceiver && room.myStatus === 'Pending' && !isActive) {
          nextUnread[key] = true;
          if (!store.alertedPending[key]) {
            store.notePendingAlerted(key);
            const name = displayName(room);
            notify(`${name} wants to connect`, {
              title: 'Connection request',
              kind: 'info',
              roomKey: key,
              avatar,
              route,
              inbox: true,
            });
            void presentLocalNotification({
              title: 'Connection request',
              body: `${name} wants to connect`,
              badge: Object.keys(nextUnread).length,
            });
          }
        }

        if (
          store.unreadKeys[key] &&
          !isActive &&
          !(isReceiver && room.myStatus === 'Pending')
        ) {
          if (!(isReceiver && room.myStatus === 'Rejected')) {
            nextUnread[key] = true;
          }
        }

        if (
          isSender &&
          (room.otherStatus === 'Accepted' || room.otherStatus === 'Rejected')
        ) {
          const st = String(room.otherStatus);
          if (store.alertedStatus[key] !== st) {
            store.noteStatusAlerted(key, st);
            const name = displayName(room);
            if (st === 'Accepted') {
              notify(`${name} accepted your connection`, {
                title: 'Connected',
                kind: 'success',
                roomKey: key,
                avatar,
                route,
                inbox: true,
              });
              void presentLocalNotification({
                title: 'Connected',
                body: `${name} accepted your connection`,
                badge: Object.keys(nextUnread).length,
              });
            } else {
              notify(`${name} declined your connection`, {
                title: 'Connection declined',
                kind: 'warning',
                roomKey: key,
                avatar,
                route,
                inbox: true,
              });
            }
          }
        }

        const activityAt =
          parseMessageDate(room.lastMessageTime)?.getTime() ?? 0;
        if (activityAt > 0) {
          const prev = store.alertedActivity[key] ?? 0;
          if (prev === 0) {
            store.noteActivityAlerted(key, activityAt);
          } else if (activityAt > prev) {
            store.noteActivityAlerted(key, activityAt);
            if (!isActive) {
              nextUnread[key] = true;
              const name = displayName(room);
              const kind = room.lastMessageType ?? 'message';
              notify(`New ${kind} from ${name}`, {
                title: 'Chat update',
                kind: 'info',
                roomKey: key,
                avatar,
                route,
                inbox: true,
              });
              void presentLocalNotification({
                title: 'Chat update',
                body: `New ${kind} from ${name}`,
                badge: Object.keys(nextUnread).length,
              });
            }
          }
        }
      }

      store.setUnreadKeys(nextUnread);
    });

    return () => {
      unsub();
      seededRef.current = false;
    };
  }, [myId, hydrated, enabled, boundUserId]);

  return null;
}
