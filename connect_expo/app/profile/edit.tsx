/**
 * Flutter `EditDetails` — avatar sheet, first/last/DOB/email, Update Profile.
 */
import { PrimaryButton } from '@/components/PrimaryButton';
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { TextField } from '@/components/TextField';
import { Brand } from '@/constants/Colors';
import { updateProfile } from '@/services/api/auth';
import { useAuthStore } from '@/store/authStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import * as ImagePicker from 'expo-image-picker';
import { router } from 'expo-router';
import React, { useMemo, useState } from 'react';
import {
  Alert,
  Image,
  Modal,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

function formatDobDisplay(raw?: string | null) {
  if (!raw) return '';
  // API may return yyyy-MM-dd or Date string
  const d = new Date(raw);
  if (!Number.isNaN(d.getTime())) {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}/${m}/${day}`;
  }
  return String(raw).replace(/-/g, '/').slice(0, 10);
}

function toApiDob(display: string) {
  return display.replace(/\//g, '-').slice(0, 10);
}

export default function EditProfileScreen() {
  const user = useAuthStore((s) => s.user);
  const token = useAuthStore((s) => s.token);
  const patchUser = useAuthStore((s) => s.patchUser);

  const [firstName, setFirstName] = useState(user?.first_name ?? '');
  const [lastName, setLastName] = useState(user?.last_name ?? '');
  const [email] = useState(user?.email ?? '');
  const [dob, setDob] = useState(formatDobDisplay(user?.dob));
  const [avatarUri, setAvatarUri] = useState<string | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  const displayName = useMemo(
    () => `${firstName} ${lastName}`.trim(),
    [firstName, lastName],
  );

  async function pick(fromCamera: boolean) {
    setSheetOpen(false);
    const perm = fromCamera
      ? await ImagePicker.requestCameraPermissionsAsync()
      : await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!perm.granted) {
      Alert.alert('Permission needed', 'Allow access to continue.');
      return;
    }
    const result = fromCamera
      ? await ImagePicker.launchCameraAsync({
          mediaTypes: ['images'],
          quality: 0.85,
        })
      : await ImagePicker.launchImageLibraryAsync({
          mediaTypes: ['images'],
          quality: 0.85,
        });
    if (!result.canceled && result.assets[0]?.uri) {
      setAvatarUri(result.assets[0].uri);
    }
  }

  async function onUpdate() {
    if (!token) return;
    if (!firstName.trim()) {
      Alert.alert('', 'Please enter first name');
      return;
    }
    if (!lastName.trim()) {
      Alert.alert('', 'Please enter last name');
      return;
    }
    if (!dob.trim()) {
      Alert.alert('', 'Please enter phone number'); // Flutter copy (DOB field)
      return;
    }
    if (!avatarUri) {
      Alert.alert('', 'Please Select a Image');
      return;
    }
    setLoading(true);
    try {
      const session = await updateProfile(token, {
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email,
        dob: toApiDob(dob),
        avatarUri,
      });
      await patchUser({
        first_name: firstName.trim(),
        last_name: lastName.trim(),
        dob: toApiDob(dob),
        avatar: session.user?.avatar ?? avatarUri,
      });
      Alert.alert('Success', 'Profile updated Successfully');
      if (router.canGoBack()) router.back();
    } catch (e) {
      Alert.alert(
        'Failure',
        e instanceof Error ? e.message : 'Something went wrong',
      );
    } finally {
      setLoading(false);
    }
  }

  const remoteAvatar = user?.avatar;
  const showUri =
    avatarUri ||
    (remoteAvatar && /^https?:\/\//i.test(remoteAvatar) ? remoteAvatar : null);

  return (
    <View style={styles.root}>
      <ScreenAppBar title="Edit Profile" />
      <ScrollView contentContainerStyle={styles.content}>
        <Pressable onPress={() => setSheetOpen(true)} style={styles.avatarWrap}>
          {showUri ? (
            <Image source={{ uri: showUri }} style={styles.avatar} />
          ) : (
            <View style={[styles.avatar, styles.avatarFallback]}>
              <MaterialIcons name="image" size={40} color={Brand.txtGrey} />
            </View>
          )}
        </Pressable>
        <Text style={styles.name}>{displayName}</Text>

        <TextField
          label="First Name"
          value={firstName}
          onChangeText={setFirstName}
          autoCapitalize="words"
        />
        <TextField
          label="Last Name"
          value={lastName}
          onChangeText={setLastName}
          autoCapitalize="words"
        />
        <TextField
          label="DOB (yyyy/MM/dd)"
          value={dob}
          onChangeText={setDob}
          placeholder="yyyy/MM/dd"
        />
        <TextField label="Email" value={email} editable={false} />

        <PrimaryButton
          label="Update Profile"
          loading={loading}
          onPress={() => void onUpdate()}
          style={{ marginTop: 24 }}
        />
      </ScrollView>

      <Modal visible={sheetOpen} transparent animationType="slide">
        <Pressable style={styles.sheetBackdrop} onPress={() => setSheetOpen(false)}>
          <View style={styles.sheet}>
            <Pressable style={styles.sheetRow} onPress={() => void pick(true)}>
              <Text style={styles.sheetText}>Camera</Text>
            </Pressable>
            <Pressable style={styles.sheetRow} onPress={() => void pick(false)}>
              <Text style={styles.sheetText}>Gallery</Text>
            </Pressable>
            <Pressable
              style={[styles.sheetRow, styles.cancelRow]}
              onPress={() => setSheetOpen(false)}
            >
              <Text style={[styles.sheetText, { color: Brand.primary }]}>Cancel</Text>
            </Pressable>
          </View>
        </Pressable>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  content: { paddingHorizontal: 30, paddingVertical: 15, paddingBottom: 40 },
  avatarWrap: { alignSelf: 'center', marginTop: 30 },
  avatar: {
    width: 105,
    height: 105,
    borderRadius: 53,
    backgroundColor: '#D1D5DB',
  },
  avatarFallback: { alignItems: 'center', justifyContent: 'center' },
  name: {
    textAlign: 'center',
    marginTop: 20,
    marginBottom: 16,
    fontSize: 16,
    color: Brand.textPrimary,
    fontWeight: '500',
  },
  sheetBackdrop: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.35)',
  },
  sheet: {
    backgroundColor: Brand.white,
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    paddingBottom: Platform.OS === 'ios' ? 28 : 16,
  },
  sheetRow: {
    paddingVertical: 16,
    alignItems: 'center',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: Brand.border,
  },
  cancelRow: { borderBottomWidth: 0 },
  sheetText: { fontSize: 17, color: Brand.textPrimary },
});
