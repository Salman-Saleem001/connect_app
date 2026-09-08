import { Brand } from '@/constants/Colors';
import React from 'react';
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  View,
  type PressableProps,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

type Props = Omit<PressableProps, 'style'> & {
  label: string;
  loading?: boolean;
  variant?: 'primary' | 'outline';
  style?: StyleProp<ViewStyle>;
};

export function PrimaryButton({
  label,
  loading,
  variant = 'primary',
  disabled,
  style,
  ...rest
}: Props) {
  const isDisabled = disabled || loading;
  const isOutline = variant === 'outline';

  if (isOutline) {
    return (
      <Pressable
        accessibilityRole="button"
        disabled={isDisabled}
        style={({ pressed }) => [
          styles.base,
          styles.outline,
          pressed && !isDisabled && styles.pressed,
          isDisabled && styles.disabled,
          style,
        ]}
        {...rest}
      >
        {loading ? (
          <ActivityIndicator color={Brand.primary} />
        ) : (
          <Text style={[styles.label, styles.outlineLabel]}>{label.toUpperCase()}</Text>
        )}
      </Pressable>
    );
  }

  return (
    <Pressable
      accessibilityRole="button"
      disabled={isDisabled}
      style={({ pressed }) => [
        styles.shadowWrap,
        pressed && !isDisabled && styles.pressed,
        isDisabled && styles.disabled,
        style,
      ]}
      {...rest}
    >
      <LinearGradient
        colors={[Brand.primaryTop, Brand.primary]}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={styles.base}
      >
        {loading ? (
          <ActivityIndicator color={Brand.white} />
        ) : (
          <Text style={styles.label}>{label.toUpperCase()}</Text>
        )}
      </LinearGradient>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  shadowWrap: {
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 7 },
    shadowOpacity: 0.12,
    shadowRadius: 10,
    elevation: 4,
  },
  base: {
    height: 55,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: Brand.borderLight,
  },
  label: {
    color: Brand.white,
    fontSize: 18,
    fontWeight: '500',
    letterSpacing: 0.3,
  },
  outlineLabel: {
    color: Brand.textPrimary,
    fontSize: 15,
  },
  pressed: {
    opacity: 0.9,
  },
  disabled: {
    opacity: 0.55,
  },
});
