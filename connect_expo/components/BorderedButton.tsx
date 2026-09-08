import { Brand } from '@/constants/Colors';
import React from 'react';
import {
  Pressable,
  StyleSheet,
  Text,
  type PressableProps,
  type StyleProp,
  type ViewStyle,
} from 'react-native';

type Props = Omit<PressableProps, 'style'> & {
  text: string;
  style?: StyleProp<ViewStyle>;
};

/** Flutter `BorderedButton` used on profile (Edit Profile / My replies). */
export function BorderedButton({ text, style, disabled, ...rest }: Props) {
  return (
    <Pressable
      accessibilityRole="button"
      disabled={disabled}
      style={({ pressed }) => [
        styles.btn,
        pressed && !disabled && styles.pressed,
        disabled && styles.disabled,
        style,
      ]}
      {...rest}
    >
      <Text style={styles.label}>{text}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  btn: {
    minWidth: 120,
    paddingHorizontal: 18,
    paddingVertical: 10,
    borderRadius: 5,
    borderWidth: 1,
    borderColor: Brand.borderLight,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Brand.white,
  },
  label: {
    color: Brand.textPrimary,
    fontSize: 14,
    fontWeight: '500',
  },
  pressed: { opacity: 0.85 },
  disabled: { opacity: 0.5 },
});
