import { Brand } from '@/constants/Colors';
import React from 'react';
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
  label?: string;
  error?: string;
  prefixIcon?: ImageSourcePropType;
  prefixIconSize?: number;
  prefixTint?: string;
  rightElement?: React.ReactNode;
};

export function TextField({
  label,
  error,
  style,
  prefixIcon,
  prefixIconSize = 16,
  prefixTint,
  rightElement,
  ...rest
}: Props) {
  return (
    <View style={styles.wrap}>
      <View style={[styles.field, error ? styles.fieldError : null]}>
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
        ) : null}
        <TextInput
          placeholder={label}
          placeholderTextColor={Brand.textLight}
          style={[styles.input, styles.inputFlex, style]}
          {...rest}
        />
        {rightElement ? <View style={styles.suffix}>{rightElement}</View> : null}
      </View>
      {error ? <Text style={styles.error}>{error}</Text> : null}
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
  wrap: {
    marginBottom: 12,
  },
  field: {
    minHeight: 56,
    borderWidth: 1,
    borderColor: Brand.border,
    borderRadius: 15,
    paddingHorizontal: 10,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Brand.white,
  },
  fieldError: {
    borderColor: Brand.primary,
  },
  prefix: {
    width: 40,
    height: 50,
    alignItems: 'center',
    justifyContent: 'center',
  },
  input: {
    fontSize: 15,
    color: Brand.textPrimary,
    paddingVertical: 16,
    margin: 0,
  },
  inputFlex: {
    flex: 1,
  },
  suffix: {
    paddingHorizontal: 6,
  },
  error: {
    marginTop: 4,
    fontSize: 12,
    color: Brand.primary,
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
    width: 22,
    height: 22,
  },
});
