/**
 * Flutter `SettingsScreen` — ACCOUNT MANAGER / PREFERENCES / MORE INFO.
 */
import { BorderedButton } from '@/components/BorderedButton';
import { PrimaryButton } from '@/components/PrimaryButton';
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { Brand } from '@/constants/Colors';
import { SupportLinks } from '@/constants/api';
import { useAuthStore } from '@/store/authStore';
import { useNotificationStore } from '@/store/notificationStore';
import { useProfileStore } from '@/store/profileStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import * as WebBrowser from 'expo-web-browser';
import { router } from 'expo-router';
import React, { useState } from 'react';
import {
  ActivityIndicator,
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

type TileProps = {
  icon: React.ComponentProps<typeof MaterialIcons>['name'];
  title: string;
  onPress?: () => void;
};

function SettingsTile({ icon, title, onPress }: TileProps) {
  return (
    <Pressable style={styles.tile} onPress={onPress} disabled={!onPress}>
      <MaterialIcons name={icon} size={22} color={Brand.txtGrey} />
      <Text style={styles.tileTitle}>{title}</Text>
    </Pressable>
  );
}

function SettingsSection({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <View>
      <Text style={styles.sectionTitle}>{title}</Text>
      {children}
    </View>
  );
}

export default function SettingsScreen() {
  const logout = useAuthStore((s) => s.logout);
  const deleteAccount = useAuthStore((s) => s.deleteAccount);
  const clearProfile = useProfileStore((s) => s.clear);
  const [logoutOpen, setLogoutOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [loggingOut, setLoggingOut] = useState(false);
  const [deleting, setDeleting] = useState(false);

  async function onConfirmLogout() {
    setLoggingOut(true);
    try {
      clearProfile();
      useNotificationStore.getState().clearInbox();
      useNotificationStore.getState().clearAllBadges();
      await useNotificationStore.getState().bindUser(null);
      await logout();
      setLogoutOpen(false);
      router.replace('/(auth)/walkthrough');
    } finally {
      setLoggingOut(false);
    }
  }

  async function onConfirmDelete() {
    setDeleting(true);
    const ok = await deleteAccount();
    setDeleting(false);
    setDeleteOpen(false);
    if (ok) {
      clearProfile();
      useNotificationStore.getState().clearAllBadges();
      await useNotificationStore.getState().bindUser(null);
      router.replace('/(auth)/walkthrough');
    }
  }

  return (
    <View style={styles.root}>
      <ScreenAppBar title="Settings" />
      <ScrollView>
        <SettingsSection title="ACCOUNT MANAGER">
          <SettingsTile
            icon="person"
            title="Personal Details"
            onPress={() => router.push('/profile/edit')}
          />
          <SettingsTile
            icon="bar-chart"
            title="Views Stats"
            onPress={() => router.push('/profile/views-stats')}
          />
          <SettingsTile
            icon="lock"
            title="Password & Security"
            onPress={() => router.push('/profile/password')}
          />
        </SettingsSection>

        <View style={styles.divider} />

        <SettingsSection title="PREFERENCES & ACTIVITY">
          <SettingsTile
            icon="notifications"
            title="Notification Center"
            onPress={() => router.push('/notifications')}
          />
          <SettingsTile
            icon="tune"
            title="Manage Alerts"
            onPress={() => router.push('/profile/notifications')}
          />
          <SettingsTile icon="language" title="Language & Region" />
          <SettingsTile
            icon="person-off"
            title="Blocked Users"
            onPress={() => router.push('/profile/blocked')}
          />
          <SettingsTile
            icon="logout"
            title="Logout Device"
            onPress={() => setLogoutOpen(true)}
          />
          <SettingsTile
            icon="no-accounts"
            title="Delete Account"
            onPress={() => setDeleteOpen(true)}
          />
        </SettingsSection>

        <View style={styles.divider} />

        <SettingsSection title="MORE INFO AND SUPPORT">
          <SettingsTile
            icon="help-outline"
            title="Help & Support"
            onPress={() => void WebBrowser.openBrowserAsync(SupportLinks.help)}
          />
          <SettingsTile
            icon="description"
            title="Terms & Conditions"
            onPress={() => void WebBrowser.openBrowserAsync(SupportLinks.terms)}
          />
          <SettingsTile
            icon="privacy-tip"
            title="Privacy Policy"
            onPress={() => void WebBrowser.openBrowserAsync(SupportLinks.privacy)}
          />
          <SettingsTile
            icon="info-outline"
            title="About Us"
            onPress={() => void WebBrowser.openBrowserAsync(SupportLinks.about)}
          />
        </SettingsSection>
      </ScrollView>

      <Modal visible={logoutOpen} transparent animationType="fade">
        <View style={styles.dialogBackdrop}>
          <View style={styles.dialog}>
            <Text style={styles.dialogTitle}>Logout Device</Text>
            <Text style={styles.dialogBody}>
              Are you sure you want to logout?
            </Text>
            {loggingOut ? (
              <ActivityIndicator color={Brand.primary} style={{ marginTop: 16 }} />
            ) : (
              <View style={styles.dialogActions}>
                <BorderedButton
                  text="Cancel"
                  style={styles.dialogBtn}
                  onPress={() => setLogoutOpen(false)}
                />
                <PrimaryButton
                  label="Logout"
                  style={styles.dialogBtn}
                  onPress={() => void onConfirmLogout()}
                />
              </View>
            )}
          </View>
        </View>
      </Modal>

      <Modal visible={deleteOpen} transparent animationType="fade">
        <View style={styles.dialogBackdrop}>
          <View style={styles.dialog}>
            <Text style={styles.dialogTitle}>Delete Account</Text>
            <Text style={styles.dialogBody}>
              Are you sure you want to delete your account?
            </Text>
            {deleting ? (
              <ActivityIndicator color={Brand.primary} style={{ marginTop: 16 }} />
            ) : (
              <View style={styles.dialogActions}>
                <BorderedButton
                  text="Cancel"
                  style={styles.dialogBtn}
                  onPress={() => setDeleteOpen(false)}
                />
                <PrimaryButton
                  label="Delete"
                  style={styles.dialogBtn}
                  onPress={() => void onConfirmDelete()}
                />
              </View>
            )}
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  sectionTitle: {
    padding: 16,
    fontSize: 14,
    color: Brand.txtGrey,
    fontWeight: '500',
  },
  tile: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  tileTitle: { fontSize: 16, color: Brand.textPrimary },
  divider: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: Brand.border,
    marginHorizontal: 20,
  },
  dialogBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  dialog: {
    width: '100%',
    backgroundColor: Brand.white,
    borderRadius: 12,
    padding: 16,
  },
  dialogTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: Brand.textPrimary,
    textAlign: 'center',
  },
  dialogBody: {
    marginTop: 10,
    fontSize: 14,
    color: Brand.textPrimary,
    textAlign: 'center',
  },
  dialogActions: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 20,
  },
  dialogBtn: { flex: 1 },
});
