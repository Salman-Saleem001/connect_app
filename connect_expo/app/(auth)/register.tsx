import { PrimaryButton } from '@/components/PrimaryButton';
import { TextField } from '@/components/TextField';
import { Brand } from '@/constants/Colors';
import { useAuthStore } from '@/store/authStore';
import { Link, Redirect, router } from 'expo-router';
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

export default function RegisterScreen() {
  const token = useAuthStore((s) => s.token);
  const isLoading = useAuthStore((s) => s.isLoading);
  const register = useAuthStore((s) => s.register);
  const clearError = useAuthStore((s) => s.clearError);

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [bio, setBio] = useState('');
  const [terms, setTerms] = useState(false);

  if (token) {
    return <Redirect href="/(tabs)" />;
  }

  async function onSubmit() {
    clearError();
    if (!firstName.trim() || !lastName.trim() || !username.trim()) {
      Alert.alert('', 'Please fill name and username');
      return;
    }
    if (!email.trim() || !password) {
      Alert.alert('', 'Please enter email and password');
      return;
    }
    if (password !== confirmPassword) {
      Alert.alert('', 'Passwords do not match');
      return;
    }
    if (!terms) {
      Alert.alert('', 'Please accept terms & conditions');
      return;
    }

    const ok = await register({
      email: email.trim(),
      password,
      password_confirmation: confirmPassword,
      first_name: firstName.trim(),
      last_name: lastName.trim(),
      username: username.trim(),
      phone: phone.trim(),
      preferences: [],
      bio: bio.trim(),
    });

    if (ok) {
      Alert.alert(
        'Success',
        'User Sign-Up Successful, Please Login and Access Enjoy The Features',
        [{ text: 'OK', onPress: () => router.replace('/(auth)/login') }],
      );
    } else {
      Alert.alert('Failure', useAuthStore.getState().error ?? 'Sign up failed');
    }
  }

  return (
    <SafeAreaView style={styles.safe}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={styles.content}
          keyboardShouldPersistTaps="handled"
        >
          <Image
            source={require('../../assets/images/kora_logo.png')}
            style={styles.logo}
            resizeMode="contain"
          />

          <Text style={styles.title}>Welcome!</Text>
          <Text style={styles.subtitle}>Let's get started!</Text>

          <TextField
            label="First Name"
            value={firstName}
            onChangeText={setFirstName}
            prefixIcon={require('../../assets/images/ic_person.png')}
            prefixIconSize={18}
            prefixTint={Brand.iconColor}
          />
          <TextField
            label="Last Name"
            value={lastName}
            onChangeText={setLastName}
            prefixIcon={require('../../assets/images/ic_person.png')}
            prefixIconSize={18}
            prefixTint={Brand.iconColor}
          />
          <TextField
            label="Username"
            autoCapitalize="none"
            value={username}
            onChangeText={setUsername}
            prefixIcon={require('../../assets/images/ic_person.png')}
            prefixIconSize={18}
            prefixTint={Brand.iconColor}
          />
          <TextField
            label="Email address"
            autoCapitalize="none"
            keyboardType="email-address"
            value={email}
            onChangeText={setEmail}
            prefixIcon={require('../../assets/images/ic_email.png')}
            prefixIconSize={13}
            prefixTint={Brand.iconColor}
          />
          <TextField
            label="Phone"
            keyboardType="phone-pad"
            value={phone}
            onChangeText={setPhone}
            prefixIcon={require('../../assets/images/ic_person.png')}
            prefixIconSize={18}
            prefixTint={Brand.iconColor}
          />
          <TextField
            label="Password"
            secureTextEntry
            value={password}
            onChangeText={setPassword}
            prefixIcon={require('../../assets/images/ic_lock.png')}
            prefixIconSize={18}
            prefixTint={Brand.iconColor}
          />
          <TextField
            label="Confirm password"
            secureTextEntry
            value={confirmPassword}
            onChangeText={setConfirmPassword}
            prefixIcon={require('../../assets/images/ic_lock.png')}
            prefixIconSize={18}
            prefixTint={Brand.iconColor}
          />
          <TextField label="Bio" multiline value={bio} onChangeText={setBio} />

          <Pressable style={styles.termsRow} onPress={() => setTerms((t) => !t)}>
            <View style={[styles.checkbox, terms && styles.checkboxOn]}>
              {terms ? <Text style={styles.checkMark}>✓</Text> : null}
            </View>
            <Text style={styles.termsText}>  Accept terms & conditions</Text>
          </Pressable>

          <PrimaryButton label="Continue" loading={isLoading} onPress={onSubmit} />

          <Link href="/(auth)/login" asChild>
            <Pressable style={styles.signInRow}>
              <Text style={styles.muted}>Already have an account? </Text>
              <Text style={styles.link}>Sign in here</Text>
            </Pressable>
          </Link>
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
    paddingHorizontal: 20,
    paddingTop: 40,
    paddingBottom: 40,
  },
  logo: {
    width: 64,
    height: 64,
    borderRadius: 20,
    marginBottom: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: Brand.black,
  },
  subtitle: {
    fontSize: 16,
    color: Brand.black,
    marginTop: 8,
    marginBottom: 34,
  },
  termsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    marginTop: 8,
  },
  checkbox: {
    width: 20,
    height: 20,
    borderWidth: 1,
    borderColor: Brand.border,
    borderRadius: 4,
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 3,
  },
  checkboxOn: {
    backgroundColor: Brand.primary,
    borderColor: Brand.primary,
  },
  checkMark: {
    color: Brand.white,
    fontSize: 12,
    fontWeight: '700',
  },
  termsText: {
    fontSize: 13,
    color: Brand.border,
  },
  signInRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 20,
  },
  muted: {
    fontSize: 13,
    color: Brand.border,
  },
  link: {
    fontSize: 13,
    color: Brand.primary,
    fontWeight: '500',
  },
});
