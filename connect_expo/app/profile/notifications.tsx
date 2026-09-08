/**
 * Flutter `NotificationSettingsScreen` — local preference + badge permission.
 */
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { Brand } from '@/constants/Colors';
import { ensureNotificationPermissions, syncAppIconBadge } from '@/services/notifications';
import { useNotificationStore } from '@/store/notificationStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import React, { useEffect } from 'react';
import { StyleSheet, Switch, Text, View } from 'react-native';

export default function NotificationSettingsScreen() {
  const receiveAlerts = useNotificationStore((s) => s.enabled);
  const badgeCount = useNotificationStore((s) => s.badgeCount);
  const setEnabled = useNotificationStore((s) => s.setEnabled);
  const clearAllBadges = useNotificationStore((s) => s.clearAllBadges);
  const hydrate = useNotificationStore((s) => s.hydrate);

  useEffect(() => {
    void hydrate();
  }, [hydrate]);

  async function onToggle(value: boolean) {
    if (value) {
      await ensureNotificationPermissions();
    } else {
      await syncAppIconBadge(0);
    }
    await setEnabled(value);
  }

  return (
    <View style={styles.root}>
      <ScreenAppBar title="Manage Notifications" />
      <Text style={styles.section}>Manage Notifications</Text>
      <View style={styles.row}>
        <MaterialIcons name="notifications-none" size={22} color={Brand.txtGrey} />
        <Text style={styles.title}>Receive important alerts</Text>
        <Switch
          value={receiveAlerts}
          onValueChange={(v) => void onToggle(v)}
          trackColor={{ false: '#D1D5DB', true: Brand.primaryBottom }}
          thumbColor={Brand.white}
        />
      </View>
      <Text style={styles.hint}>
        In-app banners for connection requests, chat updates, posts, and stories.
        Unread items also show as a count on the app icon and Chats tab
        {badgeCount > 0 ? ` (currently ${badgeCount})` : ''}.
      </Text>
      {badgeCount > 0 ? (
        <View style={styles.clearRow}>
          <Text style={styles.clearLabel} onPress={clearAllBadges}>
            Clear badge count
          </Text>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  section: {
    padding: 16,
    fontSize: 14,
    color: Brand.txtGrey,
    fontWeight: '500',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  title: { flex: 1, fontSize: 16, color: Brand.textPrimary },
  hint: {
    paddingHorizontal: 16,
    paddingTop: 12,
    fontSize: 13,
    lineHeight: 18,
    color: Brand.txtGrey,
  },
  clearRow: { paddingHorizontal: 16, paddingTop: 16 },
  clearLabel: {
    fontSize: 15,
    fontWeight: '600',
    color: Brand.primary,
  },
});
