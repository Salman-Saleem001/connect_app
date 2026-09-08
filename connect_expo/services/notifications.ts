import * as Notifications from 'expo-notifications';
import { AppState, Platform } from 'react-native';

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

let configured = false;
let lastBadge = -1;

/** Request alert + badge permission (needed for home-screen icon count). */
export async function ensureNotificationPermissions(): Promise<boolean> {
  if (Platform.OS === 'web') return false;
  try {
    if (!configured) {
      if (Platform.OS === 'android') {
        await Notifications.setNotificationChannelAsync('important', {
          name: 'Important alerts',
          importance: Notifications.AndroidImportance.HIGH,
          vibrationPattern: [0, 250, 250, 250],
          lightColor: '#EF274D',
          showBadge: true,
        });
      }
      configured = true;
    }
    const current = await Notifications.getPermissionsAsync();
    if (
      current.granted ||
      current.ios?.status === Notifications.IosAuthorizationStatus.PROVISIONAL
    ) {
      return true;
    }
    const asked = await Notifications.requestPermissionsAsync({
      ios: {
        allowAlert: true,
        allowBadge: true,
        allowSound: true,
      },
    });
    return (
      asked.granted ||
      asked.ios?.status === Notifications.IosAuthorizationStatus.PROVISIONAL
    );
  } catch {
    return false;
  }
}

/**
 * Push the total unread count onto the home-screen app icon.
 * iOS: always via setBadgeCountAsync.
 * Android: setBadgeCountAsync + badge on delivered notifications (launcher-dependent).
 */
export async function syncAppIconBadge(count: number) {
  if (Platform.OS === 'web') return;
  const n = Math.max(0, Math.floor(count));
  try {
    const ok = await ensureNotificationPermissions();
    if (!ok) return;
    lastBadge = n;
    await Notifications.setBadgeCountAsync(n);
  } catch {
    // Some Android launchers ignore badges; iOS / Samsung / etc. still work
  }
}

/** Re-apply last known badge when returning from background. */
export function getLastSyncedBadge() {
  return lastBadge < 0 ? 0 : lastBadge;
}

/** System notification when app is backgrounded; also stamps icon badge count. */
export async function presentLocalNotification(opts: {
  title: string;
  body: string;
  badge?: number;
}) {
  if (Platform.OS === 'web') return;
  if (AppState.currentState === 'active') return;
  try {
    const ok = await ensureNotificationPermissions();
    if (!ok) return;
    const badge =
      opts.badge != null ? Math.max(0, Math.floor(opts.badge)) : getLastSyncedBadge();
    await Notifications.scheduleNotificationAsync({
      content: {
        title: opts.title,
        body: opts.body,
        sound: true,
        badge,
        ...(Platform.OS === 'android' ? { channelId: 'important' } : {}),
      },
      trigger: null,
    });
    if (opts.badge != null) {
      await syncAppIconBadge(opts.badge);
    }
  } catch {
    // ignore
  }
}
