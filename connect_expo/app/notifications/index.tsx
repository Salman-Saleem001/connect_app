/**
 * In-app notification center — list of alerts with deep links.
 */
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { Brand } from '@/constants/Colors';
import { useAuthStore } from '@/store/authStore';
import {
  useNotificationStore,
  type InboxItem,
  type ToastKind,
} from '@/store/notificationStore';
import { formatRelativeChatTime } from '@/utils/chatTime';
import { navigateInboxRoute } from '@/utils/notificationNav';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router } from 'expo-router';
import React from 'react';
import {
  FlatList,
  Image,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';

function kindMeta(kind: ToastKind) {
  switch (kind) {
    case 'success':
      return { color: '#22C55E', icon: 'check-circle' as const };
    case 'warning':
      return { color: '#F59E0B', icon: 'warning' as const };
    case 'error':
      return { color: Brand.primary, icon: 'error' as const };
    default:
      return { color: Brand.primary, icon: 'notifications' as const };
  }
}

function InboxRow({
  item,
  onPress,
}: {
  item: InboxItem;
  onPress: () => void;
}) {
  const meta = kindMeta(item.kind);
  const when = formatRelativeChatTime(item.createdAt) || 'just Now';

  return (
    <Pressable
      style={[styles.row, !item.read && styles.rowUnread]}
      onPress={onPress}
    >
      {item.avatar && /^https?:\/\//i.test(item.avatar) ? (
        <Image source={{ uri: item.avatar }} style={styles.avatar} />
      ) : (
        <View style={[styles.avatar, styles.avatarFallback, { backgroundColor: meta.color }]}>
          <MaterialIcons name={meta.icon} size={22} color={Brand.white} />
        </View>
      )}
      <View style={styles.body}>
        <View style={styles.titleRow}>
          <Text style={styles.title} numberOfLines={1}>
            {item.title}
          </Text>
          {!item.read ? <View style={styles.dot} /> : null}
        </View>
        <Text style={styles.message} numberOfLines={2}>
          {item.message}
        </Text>
        <Text style={styles.time}>{when}</Text>
      </View>
      <MaterialIcons name="chevron-right" size={22} color={Brand.txtGrey} />
    </Pressable>
  );
}

export default function NotificationsInboxScreen() {
  const userId = useAuthStore((s) =>
    s.user?.id != null ? String(s.user.id) : null,
  );
  const rawInbox = useNotificationStore((s) => s.inbox);
  const inbox = rawInbox.filter((i) => !userId || i.userId === userId);
  const markInboxRead = useNotificationStore((s) => s.markInboxRead);
  const markAllInboxRead = useNotificationStore((s) => s.markAllInboxRead);
  const clearInbox = useNotificationStore((s) => s.clearInbox);
  const unread = inbox.filter((i) => !i.read).length;

  function onOpen(item: InboxItem) {
    markInboxRead(item.id);
    if (item.roomKey) {
      useNotificationStore.getState().markRoomSeen(item.roomKey);
    }
    navigateInboxRoute(item.route);
  }

  return (
    <View style={styles.root}>
      <ScreenAppBar
        title="Notifications"
        right={
          <Pressable
            onPress={() => router.push('/profile/notifications')}
            hitSlop={10}
            style={styles.settingsBtn}
          >
            <MaterialIcons name="settings" size={22} color={Brand.primaryIconColor} />
          </Pressable>
        }
      />

      <View style={styles.toolbar}>
        <Text style={styles.toolbarLabel}>
          {unread > 0 ? `${unread} unread` : 'All caught up'}
        </Text>
        <View style={styles.toolbarActions}>
          {unread > 0 ? (
            <Pressable onPress={markAllInboxRead} hitSlop={8}>
              <Text style={styles.link}>Mark all read</Text>
            </Pressable>
          ) : null}
          {inbox.length > 0 ? (
            <Pressable onPress={clearInbox} hitSlop={8}>
              <Text style={[styles.link, styles.clear]}>Clear</Text>
            </Pressable>
          ) : null}
        </View>
      </View>

      <FlatList
        data={inbox}
        keyExtractor={(item) => item.id}
        contentContainerStyle={
          inbox.length === 0 ? styles.emptyWrap : styles.list
        }
        ListEmptyComponent={
          <View style={styles.empty}>
            <MaterialIcons name="notifications-none" size={48} color={Brand.border} />
            <Text style={styles.emptyTitle}>No notifications yet</Text>
            <Text style={styles.emptySub}>
              Connection requests, chat updates, and other alerts will show up here.
            </Text>
          </View>
        }
        renderItem={({ item }) => (
          <InboxRow item={item} onPress={() => onOpen(item)} />
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  settingsBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  toolbar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: Brand.borderLight,
  },
  toolbarLabel: { fontSize: 13, color: Brand.txtGrey, fontWeight: '500' },
  toolbarActions: { flexDirection: 'row', gap: 16 },
  link: { fontSize: 13, fontWeight: '700', color: Brand.primary },
  clear: { color: Brand.txtGrey },
  list: { paddingBottom: 40 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: Brand.borderLight,
    backgroundColor: Brand.white,
  },
  rowUnread: {
    backgroundColor: 'rgba(239,39,77,0.04)',
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: Brand.bgGrey,
  },
  avatarFallback: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  body: { flex: 1 },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  title: {
    flex: 1,
    fontSize: 15,
    fontWeight: '700',
    color: Brand.textPrimary,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: Brand.primary,
  },
  message: {
    marginTop: 2,
    fontSize: 14,
    color: Brand.lightText,
    lineHeight: 18,
  },
  time: {
    marginTop: 4,
    fontSize: 12,
    color: Brand.txtGrey,
  },
  emptyWrap: { flexGrow: 1, justifyContent: 'center' },
  empty: {
    alignItems: 'center',
    paddingHorizontal: 40,
    gap: 8,
  },
  emptyTitle: {
    marginTop: 8,
    fontSize: 17,
    fontWeight: '700',
    color: Brand.textPrimary,
  },
  emptySub: {
    textAlign: 'center',
    fontSize: 14,
    color: Brand.txtGrey,
    lineHeight: 20,
  },
});
