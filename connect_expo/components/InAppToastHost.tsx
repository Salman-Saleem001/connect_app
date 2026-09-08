import { Brand } from '@/constants/Colors';
import {
  useNotificationStore,
  type InAppToast,
  type ToastKind,
} from '@/store/notificationStore';
import { navigateInboxRoute } from '@/utils/notificationNav';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router } from 'expo-router';
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

function kindStyle(kind: ToastKind) {
  switch (kind) {
    case 'success':
      return { bg: '#22C55E', icon: 'check-circle' as const };
    case 'warning':
      return { bg: '#F59E0B', icon: 'warning' as const };
    case 'error':
      return { bg: Brand.primary, icon: 'error' as const };
    default:
      return { bg: Brand.primary, icon: 'info' as const };
  }
}

function ToastCard({
  toast,
  onPress,
}: {
  toast: InAppToast;
  onPress: () => void;
}) {
  const meta = kindStyle(toast.kind);
  return (
    <Pressable style={[styles.card, { borderLeftColor: meta.bg }]} onPress={onPress}>
      <View style={[styles.iconWrap, { backgroundColor: meta.bg }]}>
        <MaterialIcons name={meta.icon} size={18} color={Brand.white} />
      </View>
      <View style={styles.copy}>
        {toast.title ? <Text style={styles.title}>{toast.title}</Text> : null}
        <Text style={styles.message} numberOfLines={3}>
          {toast.message}
        </Text>
      </View>
      <MaterialIcons name="chevron-right" size={18} color={Brand.txtGrey} />
    </Pressable>
  );
}

/** Flutter-style overlay toasts — mount once in root layout. */
export function InAppToastHost() {
  const insets = useSafeAreaInsets();
  const toasts = useNotificationStore((s) => s.toasts);
  const inbox = useNotificationStore((s) => s.inbox);
  const dismissToast = useNotificationStore((s) => s.dismissToast);
  const markInboxRead = useNotificationStore((s) => s.markInboxRead);

  if (!toasts.length) return null;

  return (
    <View
      pointerEvents="box-none"
      style={[styles.host, { top: insets.top + 8 }]}
    >
      {toasts.map((t) => (
        <ToastCard
          key={t.id}
          toast={t}
          onPress={() => {
            dismissToast(t.id);
            if (t.inboxId) {
              const item = inbox.find((i) => i.id === t.inboxId);
              markInboxRead(t.inboxId);
              if (item?.roomKey) {
                useNotificationStore.getState().markRoomSeen(item.roomKey);
              }
              if (item?.route) {
                navigateInboxRoute(item.route);
                return;
              }
            }
            router.push('/notifications');
          }}
        />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  host: {
    position: 'absolute',
    left: 12,
    right: 12,
    zIndex: 9999,
    elevation: 9999,
    gap: 8,
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    backgroundColor: Brand.white,
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 12,
    borderWidth: 1,
    borderColor: Brand.borderLight,
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOpacity: 0.12,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
    elevation: 6,
  },
  iconWrap: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  copy: { flex: 1 },
  title: {
    fontSize: 13,
    fontWeight: '700',
    color: Brand.textPrimary,
    marginBottom: 2,
  },
  message: {
    fontSize: 14,
    color: Brand.lightText,
    lineHeight: 18,
  },
});
