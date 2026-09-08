import { PrimaryButton } from '@/components/PrimaryButton';
import { Brand } from '@/constants/Colors';
import { postsApi } from '@/services/api';
import { useAuthStore } from '@/store/authStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useState } from 'react';
import {
  Alert,
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function RateScreen() {
  const params = useLocalSearchParams<{
    userAvatar: string;
    videoId: string;
    name: string;
    bio: string;
  }>();
  const token = useAuthStore((s) => s.token);
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState('');
  const [loading, setLoading] = useState(false);

  async function onSubmit() {
    if (!rating) {
      Alert.alert('', 'Please select a rating');
      return;
    }
    if (!token || !params.videoId) return;
    setLoading(true);
    try {
      await postsApi.ratePost(token, Number(params.videoId), rating, comment);
      Alert.alert('Success', 'Rating submitted', [
        { text: 'OK', onPress: () => router.back() },
      ]);
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Failed to rate');
    } finally {
      setLoading(false);
    }
  }

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.appBar}>
        <Pressable style={styles.circleBtn} onPress={() => router.back()}>
          <MaterialIcons name="arrow-back-ios-new" size={20} color={Brand.primaryIconColor} />
        </Pressable>
        <Text style={styles.title}>Rate</Text>
        <View style={{ width: 48 }} />
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.userRow}>
          <Image
            source={{
              uri:
                params.userAvatar && /^https?:\/\//i.test(params.userAvatar)
                  ? params.userAvatar
                  : 'https://cdn-icons-png.flaticon.com/512/61/61205.png',
            }}
            style={styles.avatar}
          />
          <Text style={styles.name}>{params.name || 'User'}</Text>
        </View>
        {params.bio ? <Text style={styles.bio}>{params.bio}</Text> : null}

        <View style={styles.divider} />

        <Text style={styles.label}>Your overall rating</Text>
        <View style={styles.stars}>
          {[1, 2, 3, 4, 5].map((n) => (
            <Pressable key={n} onPress={() => setRating(n)} hitSlop={6}>
              <MaterialIcons
                name={n <= rating ? 'star' : 'star-border'}
                size={36}
                color={Brand.primary}
              />
            </Pressable>
          ))}
        </View>

        <TextInput
          style={styles.input}
          placeholder="Write a review"
          placeholderTextColor={Brand.txtGrey}
          multiline
          value={comment}
          onChangeText={setComment}
        />

        <PrimaryButton label="Submit" loading={loading} onPress={onSubmit} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Brand.white },
  appBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 8,
    minHeight: 56,
  },
  circleBtn: {
    margin: 8,
    padding: 10,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: Brand.border,
  },
  title: { fontSize: 22, fontWeight: '700', color: Brand.textPrimary },
  content: { padding: 16 },
  userRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: { width: 80, height: 80, borderRadius: 40, backgroundColor: Brand.border },
  name: { marginLeft: 10, fontSize: 18, color: Brand.lightText, fontWeight: '500' },
  bio: { marginTop: 12, marginLeft: 90, color: Brand.txtGrey, fontSize: 14 },
  divider: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: Brand.border,
    marginVertical: 16,
  },
  label: { fontSize: 15, color: Brand.textLight, marginBottom: 10 },
  stars: { flexDirection: 'row', gap: 6, marginBottom: 20 },
  input: {
    minHeight: 100,
    borderWidth: 1,
    borderColor: Brand.border,
    borderRadius: 12,
    padding: 12,
    marginBottom: 20,
    textAlignVertical: 'top',
    color: Brand.black,
  },
});
