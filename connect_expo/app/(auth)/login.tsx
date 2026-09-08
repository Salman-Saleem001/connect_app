import { AuthTextField, SocialButton } from '@/components/AuthTextField';
import { PrimaryButton } from '@/components/PrimaryButton';
import { Brand } from '@/constants/Colors';
import { useAuthStore } from '@/store/authStore';
import { notify } from '@/store/notificationStore';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import { Link, Redirect } from 'expo-router';
import React, { useState } from 'react';
import {
  Alert,
  Image,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

const EMAIL_RE =
  /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;

export default function LoginScreen() {
  const token = useAuthStore((s) => s.token);
  const isLoading = useAuthStore((s) => s.isLoading);
  const login = useAuthStore((s) => s.login);
  const clearError = useAuthStore((s) => s.clearError);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [obscure, setObscure] = useState(true);

  if (token) {
    return <Redirect href="/(tabs)" />;
  }

  async function onSubmit() {
    clearError();
    const trimmed = email.trim();
    if (!trimmed) {
      Alert.alert('', 'Please enter email');
      return;
    }
    if (!EMAIL_RE.test(trimmed)) {
      Alert.alert('', 'Please enter a valid email');
      return;
    }
    if (!password) {
      Alert.alert('', 'Please enter password');
      return;
    }

    const ok = await login(trimmed, password);
    if (!ok) {
      Alert.alert('Failure', useAuthStore.getState().error ?? 'Login failed');
    } else {
      notify('Welcome back', { title: 'Signed in', kind: 'success' });
    }
  }

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'bottom']}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={styles.content}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* Flutter: ClipRRect radius 20 + Image scale 10 → ~108px */}
          <View style={styles.logoWrap}>
            <Image
              source={require('../../assets/images/kora_logo.png')}
              style={styles.logo}
              resizeMode="cover"
            />
          </View>

          <View style={{ height: 30 }} />

          <Text style={styles.title}>Welcome to Connect Giant</Text>

          <View style={{ height: 34 }} />

          <AuthTextField
            label="Email address"
            autoCapitalize="none"
            autoCorrect={false}
            keyboardType="email-address"
            textContentType="emailAddress"
            value={email}
            onChangeText={setEmail}
            prefixIcon={require('../../assets/images/ic_email.png')}
            prefixIconSize={13}
          />

          <AuthTextField
            label="Password"
            secureTextEntry={obscure}
            textContentType="password"
            value={password}
            onChangeText={setPassword}
            prefixIcon={require('../../assets/images/ic_lock.png')}
            prefixIconSize={18}
            prefixTint={Brand.bgGrey}
            rightElement={
              <Pressable onPress={() => setObscure((v) => !v)} hitSlop={8}>
                <FontAwesome
                  name={obscure ? 'eye' : 'eye-slash'}
                  size={22}
                  color={Brand.bgGrey}
                />
              </Pressable>
            }
          />

          <View style={{ height: 10 }} />

          <View style={styles.forgotRow}>
            <Pressable
              onPress={() =>
                Alert.alert('Coming soon', 'Forgot password will be ported next.')
              }
              hitSlop={8}
            >
              <Text style={styles.forgot}>Forget Password?</Text>
            </Pressable>
          </View>

          <View style={{ height: 20 }} />

          <PrimaryButton label="SIGN IN" loading={isLoading} onPress={onSubmit} />

          <View style={{ height: 23 }} />

          <Text style={styles.or}>or login with</Text>

          <View style={{ height: 23 }} />

          <View style={styles.socialRow}>
            <SocialButton
              onPress={() =>
                Alert.alert('Coming soon', 'Google sign-in will use /auth/social-login')
              }
            />
            {Platform.OS === 'ios' ? (
              <SocialButton
                onPress={() =>
                  Alert.alert('Coming soon', 'Apple sign-in will use /auth/social-login')
                }
                icon={<FontAwesome name="apple" size={24} color={Brand.black} />}
              />
            ) : null}
          </View>

          <View style={{ height: 20 }} />

          <View style={styles.registerRow}>
            <Text style={styles.registerMuted}>Don't have an account? </Text>
            <Link href="/(auth)/register" asChild>
              <Pressable hitSlop={8}>
                <Text style={styles.registerLink}> Register Now</Text>
              </Pressable>
            </Link>
          </View>

          <View style={{ height: 20 }} />
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: Brand.white,
  },
  flex: {
    flex: 1,
  },
  content: {
    paddingLeft: 20,
    paddingRight: 20,
    paddingTop: 40,
    paddingBottom: 10,
  },
  logoWrap: {
    alignSelf: 'flex-start',
    borderRadius: 20,
    overflow: 'hidden',
  },
  logo: {
    width: 108,
    height: 108,
  },
  title: {
    fontSize: 26,
    fontWeight: '700',
    color: Brand.black,
  },
  forgotRow: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  forgot: {
    fontSize: 13,
    fontWeight: '500',
    color: Brand.border,
    padding: 8,
  },
  or: {
    textAlign: 'center',
    color: Brand.lightText,
    fontSize: 12,
    fontWeight: '500',
  },
  socialRow: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
  },
  registerRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  registerMuted: {
    fontSize: 12,
    fontWeight: '500',
    color: Brand.lightText,
  },
  registerLink: {
    fontSize: 12,
    fontWeight: '500',
    color: Brand.primaryBottom,
  },
});
