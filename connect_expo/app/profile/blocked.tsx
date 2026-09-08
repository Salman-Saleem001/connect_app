/**
 * Flutter `BlockedUsers` — Manage Users + Unblock.
 */
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { Brand } from '@/constants/Colors';
import { useAuthStore } from '@/store/authStore';
import { useProfileStore } from '@/store/profileStore';
import { useFocusEffect } from 'expo-router';
import React, { useCallback } from 'react';
import {
  ActivityIndicator,
  Image,
  Pressable,
  FlatList,
  StyleSheet,
  Text,
  View,
} from 'react-native';

export default function BlockedUsersScreen() {
  const token = useAuthStore((s) => s.token);
  const blocked = useProfileStore((s) => s.blocked);
  const loading = useProfileStore((s) => s.loadingBlocked);
  const fetchBlocked = useProfileStore((s) => s.fetchBlocked);
  const unblock = useProfileStore((s) => s.unblock);

  useFocusEffect(
    useCallback(() => {
      if (token) void fetchBlocked(token);
    }, [token, fetchBlocked]),
  );

  return (
    <View style={styles.root}>
      <ScreenAppBar title="Manage Users" />
      <Text style={styles.section}>Blocked Users</Text>
      {loading ? (
        <ActivityIndicator color={Brand.primary} style={{ marginTop: 24 }} />
      ) : (
        <FlatList
          data={blocked}
          keyExtractor={(item) => String(item.id)}
          contentContainerStyle={styles.list}
          ListEmptyComponent={
            <Text style={styles.empty}>No blocked users</Text>
          }
          renderItem={({ item }) => {
            const avatar = item.avatar;
            return (
              <View style={styles.row}>
                {avatar && /^https?:\/\//i.test(avatar) ? (
                  <Image source={{ uri: avatar }} style={styles.avatar} />
                ) : (
                  <View style={[styles.avatar, styles.avatarFallback]} />
                )}
                <View style={styles.meta}>
                  <Text style={styles.name}>
                    {item.first_name ?? ''} {item.last_name ?? ''}
                  </Text>
                  <Text style={styles.username}>@{item.username ?? ''}</Text>
                </View>
                <Pressable
                  style={styles.unblock}
                  onPress={() => {
                    if (!token || !item.id) return;
                    void unblock(token, item.id);
                  }}
                >
                  <Text style={styles.unblockText}>Unblock</Text>
                </Pressable>
              </View>
            );
          }}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  section: {
    padding: 16,
    fontSize: 14,
    color: Brand.txtGrey,
    fontWeight: '500',
  },
  list: { paddingHorizontal: 20, paddingBottom: 40 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 14,
    gap: 12,
  },
  avatar: { width: 50, height: 50, borderRadius: 25, backgroundColor: Brand.bgGrey },
  avatarFallback: {},
  meta: { flex: 1 },
  name: { fontSize: 14, color: Brand.textPrimary },
  username: { fontSize: 13, color: Brand.borderLight, marginTop: 2 },
  unblock: {
    backgroundColor: 'rgb(233,75,62)',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 8,
  },
  unblockText: { color: Brand.white, fontSize: 13, fontWeight: '500' },
  empty: { textAlign: 'center', color: Brand.txtGrey, marginTop: 40 },
});
