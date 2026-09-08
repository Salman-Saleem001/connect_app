import { Brand } from '@/constants/Colors';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router } from 'expo-router';
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type Props = {
  title: string;
  backButton?: boolean;
  right?: React.ReactNode;
};

/** Flutter `customAppBar` — title + optional circular back / trailing action. */
export function ScreenAppBar({ title, backButton = true, right }: Props) {
  const insets = useSafeAreaInsets();
  return (
    <View style={[styles.bar, { paddingTop: insets.top + 8 }]}>
      <View style={styles.side}>
        {backButton ? (
          <Pressable
            onPress={() => {
              if (router.canGoBack()) router.back();
              else router.replace('/(tabs)/profile');
            }}
            style={styles.circleBtn}
            hitSlop={8}
          >
            <MaterialIcons name="arrow-back-ios-new" size={18} color={Brand.primaryIconColor} />
          </Pressable>
        ) : (
          <View style={styles.circlePlaceholder} />
        )}
      </View>
      <Text style={styles.title} numberOfLines={1}>
        {title}
      </Text>
      <View style={[styles.side, styles.sideRight]}>{right ?? <View style={styles.circlePlaceholder} />}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  bar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingBottom: 10,
    backgroundColor: Brand.white,
  },
  side: { width: 48, alignItems: 'flex-start' },
  sideRight: { alignItems: 'flex-end' },
  title: {
    flex: 1,
    textAlign: 'center',
    fontSize: 18,
    fontWeight: '600',
    color: Brand.textPrimary,
  },
  circleBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: Brand.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  circlePlaceholder: { width: 40, height: 40 },
});
