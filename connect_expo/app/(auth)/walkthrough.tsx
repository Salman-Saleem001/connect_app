import { PrimaryButton } from '@/components/PrimaryButton';
import { Brand } from '@/constants/Colors';
import { router } from 'expo-router';
import React, { useState } from 'react';
import {
  Dimensions,
  Image,
  ImageBackground,
  NativeScrollEvent,
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

const { width, height } = Dimensions.get('window');

const SLIDES = [
  {
    title: 'Dream. Connect. Do.',
    subtitle: 'Connect to the things you want, need & love',
    image: require('../../assets/images/bg_image1.png'),
  },
  {
    title: 'Dream. Connect. Do.',
    subtitle: 'Connect to the things you want, need & love',
    image: require('../../assets/images/bg_image.png'),
  },
];

export default function WalkthroughScreen() {
  const [index, setIndex] = useState(0);

  function onScroll(e: NativeSyntheticEvent<NativeScrollEvent>) {
    const i = Math.round(e.nativeEvent.contentOffset.x / width);
    if (i !== index && i >= 0 && i < SLIDES.length) setIndex(i);
  }

  return (
    <View style={styles.root}>
      <ScrollView
        horizontal
        pagingEnabled
        bounces={false}
        showsHorizontalScrollIndicator={false}
        onScroll={onScroll}
        scrollEventThrottle={16}
        style={StyleSheet.absoluteFill}
      >
        {SLIDES.map((slide, i) => (
          <ImageBackground
            key={i}
            source={slide.image}
            style={styles.slide}
            resizeMode="cover"
          />
        ))}
      </ScrollView>

      <SafeAreaView pointerEvents="box-none" style={styles.overlay} edges={['top', 'bottom']}>
        <View pointerEvents="box-none" style={styles.content}>
          <View style={styles.topRow}>
            <Image
              source={require('../../assets/images/kora_logo.png')}
              style={styles.logo}
              resizeMode="contain"
            />
          </View>

          <View pointerEvents="none" style={styles.spacer} />

          <View pointerEvents="box-none" style={styles.bottomBlock}>
            <View pointerEvents="none" style={styles.copy}>
              <Text style={styles.title}>{SLIDES[index].title}</Text>
              <Text style={styles.subtitle}>{SLIDES[index].subtitle}</Text>
            </View>

            <View pointerEvents="none" style={styles.dots}>
              {SLIDES.map((_, i) => (
                <View
                  key={i}
                  style={[styles.dot, { opacity: index === i ? 1 : 0.4 }]}
                />
              ))}
            </View>

            <View style={styles.buttonSpacer} />

            <PrimaryButton
              label="Get Started"
              onPress={() => router.push('/(auth)/login')}
            />
            <View style={styles.bottomPad} />
          </View>
        </View>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: Brand.black,
  },
  slide: {
    width,
    height,
  },
  overlay: {
    flex: 1,
    paddingHorizontal: 20,
  },
  content: {
    flex: 1,
    width: '100%',
  },
  topRow: {
    alignItems: 'flex-start',
  },
  logo: {
    width: 110,
    height: 110,
    borderRadius: 22,
  },
  spacer: {
    flex: 1,
  },
  bottomBlock: {
    width: '100%',
  },
  copy: {
    padding: 8,
    marginBottom: 24,
  },
  title: {
    color: Brand.white,
    fontSize: 28,
    fontWeight: '700',
    textAlign: 'center',
  },
  subtitle: {
    color: Brand.white,
    fontSize: 16,
    textAlign: 'center',
  },
  dots: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginBottom: 0,
    gap: 5,
  },
  dot: {
    width: 16,
    height: 16,
    borderRadius: 60,
    backgroundColor: '#D9D9D9',
  },
  buttonSpacer: {
    height: 56,
  },
  bottomPad: {
    height: 40,
  },
});
