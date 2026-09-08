/**
 * Flutter `SuccessUploaded` after creating a feed post.
 */
import { PrimaryButton } from '@/components/PrimaryButton';
import { Brand } from '@/constants/Colors';
import { router } from 'expo-router';
import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default function PostSuccessScreen() {
  const insets = useSafeAreaInsets();

  function onContinue() {
    if (router.canDismiss()) router.dismissAll();
    router.replace('/(tabs)');
  }

  return (
    <View style={styles.root}>
      <Image
        source={require('../../assets/images/bg_image1.png')}
        style={styles.bg}
        resizeMode="cover"
      />
      <Text style={[styles.dream, { top: insets.top + 20 }]}>Dream. Connect. Do.</Text>
      <View style={[styles.footer, { paddingBottom: Math.max(insets.bottom, 20) }]}>
        <Text style={styles.title}>Successful Upload</Text>
        <Text style={styles.sub}>Your Dream Connection starts Now</Text>
        <PrimaryButton label="Continue" onPress={onContinue} style={{ marginTop: 50 }} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#000' },
  bg: { ...StyleSheet.absoluteFill, width: '100%', height: '100%' },
  dream: {
    position: 'absolute',
    left: 0,
    right: 0,
    textAlign: 'center',
    color: Brand.white,
    fontSize: 16,
    fontWeight: '600',
    zIndex: 2,
  },
  footer: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: Brand.white,
    paddingHorizontal: 30,
    paddingTop: 44,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    color: Brand.black,
    textAlign: 'center',
  },
  sub: {
    marginTop: 8,
    fontSize: 16,
    color: Brand.txtGrey,
    textAlign: 'center',
  },
});
