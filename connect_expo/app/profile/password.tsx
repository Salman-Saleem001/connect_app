/**
 * Flutter Settings → Password & Security → `ForgetPassword(fromChangePassword: true)`.
 * Backend OTP is stubbed as in Flutter (`0000`).
 */
import { PrimaryButton } from '@/components/PrimaryButton';
import { TextField } from '@/components/TextField';
import { Brand } from '@/constants/Colors';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import {
  Alert,
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default function ChangePasswordScreen() {
  const insets = useSafeAreaInsets();
  const [email, setEmail] = useState('');

  function onSubmit() {
    if (!email.trim()) {
      Alert.alert('', 'Please enter email');
      return;
    }
    Alert.alert('OTP', 'Use code 0000 to continue (same as Flutter stub).', [
      {
        text: 'OK',
        onPress: () => {
          if (router.canGoBack()) router.back();
        },
      },
    ]);
  }

  return (
    <View style={[styles.root, { paddingTop: insets.top }]}>
      <Pressable
        style={styles.back}
        onPress={() => (router.canGoBack() ? router.back() : router.replace('/profile/settings'))}
        hitSlop={10}
      >
        <MaterialIcons name="arrow-back-ios-new" size={20} color={Brand.primaryIconColor} />
      </Pressable>
      <ScrollView contentContainerStyle={styles.content}>
        <Image
          source={require('../../assets/images/kora_logo.png')}
          style={styles.logo}
          resizeMode="contain"
        />
        <Text style={styles.heading}>Change Password!</Text>
        <Text style={styles.sub}>Recover Password.</Text>
        <TextField
          label="Email"
          value={email}
          onChangeText={setEmail}
          keyboardType="email-address"
          autoCapitalize="none"
          prefixIcon={require('../../assets/images/ic_email.png')}
        />
        <PrimaryButton label="Submit" onPress={onSubmit} style={{ marginTop: 20 }} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  back: {
    marginLeft: 16,
    marginTop: 8,
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: Brand.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: { paddingHorizontal: 20, paddingTop: 20, paddingBottom: 40 },
  logo: { width: 72, height: 72, borderRadius: 16, marginBottom: 30 },
  heading: {
    fontSize: 28,
    fontWeight: '700',
    color: Brand.textPrimary,
    marginBottom: 8,
  },
  sub: { fontSize: 16, color: Brand.textLight, marginBottom: 34 },
});
