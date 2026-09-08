import { Brand } from '@/constants/Colors';
import React, { useState } from 'react';
import {
  Image,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
  type ImageSourcePropType,
  type TextInputProps,
} from 'react-native';

type Props = TextInputProps & {
  label: string;
  prefixIcon?: ImageSourcePropType;
  prefixIconSize?: number;
  prefixTint?: string;
  rightElement?: React.ReactNode;
};

/** Mirrors Flutter `customTextFiled` (floating label + outline). */
export function AuthTextField({
  label,
  prefixIcon,
  prefixIconSize = 16,
  prefixTint,
  rightElement,
  value,
  onFocus,
  onBlur,
  style,
  ...rest
}: Props) {
  const [focused, setFocused] = useState(false);
  const hasValue = String(value ?? '').length > 0;
  const floated = focused || hasValue;

  return (
    <View
      style={[
        styles.field,
        focused ? styles.fieldFocused : styles.fieldIdle,
      ]}
    >
      {prefixIcon ? (
        <View style={styles.prefix}>
          <Image
            source={prefixIcon}
            style={{
              width: prefixIconSize,
              height: prefixIconSize,
              tintColor: prefixTint,
              resizeMode: 'contain',
            }}
          />
        </View>
      ) : (
        <View style={styles.prefixSpacer} />
      )}

      <View style={styles.inputWrap}>
        <Text
          style={[
            styles.label,
            floated ? styles.labelFloated : styles.labelRest,
            focused && styles.labelFocused,
          ]}
          pointerEvents="none"
        >
          {label}
        </Text>
        <TextInput
          value={value}
          style={[styles.input, style]}
          placeholder=""
          onFocus={(e) => {
            setFocused(true);
            onFocus?.(e);
          }}
          onBlur={(e) => {
            setFocused(false);
            onBlur?.(e);
          }}
          {...rest}
        />
      </View>

      {rightElement ? <View style={styles.suffix}>{rightElement}</View> : null}
    </View>
  );
}

export function SocialButton({
  onPress,
  icon,
}: {
  onPress: () => void;
  icon?: React.ReactNode;
}) {
  return (
    <Pressable onPress={onPress} style={styles.social}>
      {icon ?? (
        <Image
          source={require('../assets/images/ic_google.png')}
          style={styles.googleIcon}
          resizeMode="contain"
        />
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  field: {
    minHeight: 56,
    borderWidth: 1,
    borderRadius: 15,
    paddingHorizontal: 4,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Brand.white,
    marginBottom: 12,
  },
  fieldIdle: {
    borderColor: Brand.border,
  },
  fieldFocused: {
    borderColor: Brand.primaryBottom,
    borderWidth: 2,
  },
  prefix: {
    width: 40,
    height: 50,
    alignItems: 'center',
    justifyContent: 'center',
  },
  prefixSpacer: {
    width: 10,
  },
  inputWrap: {
    flex: 1,
    justifyContent: 'center',
    paddingTop: 10,
    paddingBottom: 6,
  },
  label: {
    position: 'absolute',
    left: 0,
    color: Brand.lightText,
  },
  labelRest: {
    top: 14,
    fontSize: 15,
    fontWeight: '400',
  },
  labelFloated: {
    top: -2,
    fontSize: 12,
    fontWeight: '400',
  },
  labelFocused: {
    color: Brand.primaryBottom,
  },
  input: {
    fontSize: 15,
    fontWeight: '500',
    color: Brand.black,
    padding: 0,
    margin: 0,
    height: 24,
  },
  suffix: {
    paddingHorizontal: 10,
    justifyContent: 'center',
  },
  social: {
    borderWidth: 1,
    borderColor: Brand.lightBorder,
    borderRadius: 15,
    paddingVertical: 20,
    paddingHorizontal: 50,
    alignItems: 'center',
    justifyContent: 'center',
  },
  googleIcon: {
    width: 24,
    height: 24,
  },
});
