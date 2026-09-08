/**
 * Flutter `ProfileScreen` — avatar, stats, Edit Profile / My replies, video grid.
 */
import { BorderedButton } from '@/components/BorderedButton';
import { ProfileVideoCard } from '@/components/ProfileVideoCard';
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { Brand } from '@/constants/Colors';
import { openChatMedia } from '@/store/mediaViewerStore';
import { useAuthStore } from '@/store/authStore';
import { useNotificationStore } from '@/store/notificationStore';
import { useProfileStore } from '@/store/profileStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router, useFocusEffect } from 'expo-router';
import React, { useCallback } from 'react';
import {
  ActivityIndicator,
  Alert,
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  useWindowDimensions,
  View,
} from 'react-native';

export default function ProfileScreen() {
  const { width } = useWindowDimensions();
  const user = useAuthStore((s) => s.user);
  const token = useAuthStore((s) => s.token);
  const badgeCount = useNotificationStore((s) => s.badgeCount);
  const posts = useProfileStore((s) => s.posts);
  const loadingPosts = useProfileStore((s) => s.loadingPosts);
  const postsFetched = useProfileStore((s) => s.postsFetched);
  const fetchMyPosts = useProfileStore((s) => s.fetchMyPosts);
  const removePost = useProfileStore((s) => s.removePost);

  useFocusEffect(
    useCallback(() => {
      if (token) void fetchMyPosts(token);
    }, [token, fetchMyPosts]),
  );

  const cardWidth = width / 3.2;
  const cardHeight = (width / 3) * 1.5;
  const username = user?.username ?? '';
  const avatar = user?.avatar;

  return (
    <View style={styles.root}>
      <ScreenAppBar
        title={username}
        backButton={false}
        right={
          <View style={styles.headerActions}>
            <Pressable
              onPress={() => router.push('/notifications')}
              style={styles.settingsBtn}
              hitSlop={8}
            >
              <MaterialIcons name="notifications-none" size={22} color={Brand.primaryIconColor} />
              {badgeCount > 0 ? (
                <View style={styles.headerBadge}>
                  <Text style={styles.headerBadgeText}>
                    {badgeCount > 99 ? '99+' : badgeCount}
                  </Text>
                </View>
              ) : null}
            </Pressable>
            <Pressable
              onPress={() => router.push('/profile/settings')}
              style={styles.settingsBtn}
              hitSlop={8}
            >
              <Image
                source={require('../../assets/images/ic_settings.png')}
                style={styles.settingsIcon}
                tintColor={Brand.primaryIconColor}
              />
            </Pressable>
          </View>
        }
      />

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.avatarWrap}>
          {avatar && /^https?:\/\//i.test(avatar) ? (
            <Image source={{ uri: avatar }} style={styles.avatar} />
          ) : (
            <View style={[styles.avatar, styles.avatarFallback]}>
              <MaterialIcons name="person" size={48} color={Brand.txtGrey} />
            </View>
          )}
        </View>

        <Text style={styles.username}>{username}</Text>

        <View style={styles.statsRow}>
          <View style={styles.stat}>
            <Text style={styles.statNum}>{user?.approved_followers_count ?? 0}</Text>
            <Text style={styles.statLabel}>Followers</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.stat}>
            <Text style={styles.statNum}>{user?.approved_followings_count ?? 0}</Text>
            <Text style={styles.statLabel}>Following</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.stat}>
            <Text style={styles.statNum}>0</Text>
            <Text style={styles.statLabel}>Likes</Text>
          </View>
        </View>

        <View style={styles.actions}>
          <BorderedButton
            text="Edit Profile"
            onPress={() => router.push('/profile/edit')}
          />
          <BorderedButton
            text="My replies"
            onPress={() => router.push('/(tabs)/chats')}
          />
        </View>

        <View style={styles.grid}>
          {loadingPosts && !postsFetched ? (
            <ActivityIndicator color={Brand.primary} style={{ marginTop: 24 }} />
          ) : postsFetched && posts.length === 0 ? (
            <Text style={styles.empty}>No Videos available</Text>
          ) : (
            posts.map((post, index) => (
              <ProfileVideoCard
                key={post.id ?? index}
                thumbnail={post.thumbnail}
                videoUrl={post.video}
                width={cardWidth}
                height={cardHeight}
                onOpen={() => {
                  if (!post.video) return;
                  openChatMedia(post.video);
                  router.push('/chat/video');
                }}
                onFollowRequests={() => {
                  if (!post.id) {
                    Alert.alert('', 'Missing video id for follow requests.');
                    return;
                  }
                  router.push({
                    pathname: '/profile/follow-requests',
                    params: {
                      videoId: String(post.id),
                      thumbnail: post.thumbnail || post.video || '',
                      name: post.title || post.info || 'Video',
                      viewsCount: String(
                        post.views_count ?? post.total_views ?? 0,
                      ),
                    },
                  });
                }}
                onStats={() => {
                  router.push(`/profile/stats/${post.id ?? 0}`);
                }}
                onDelete={() => {
                  if (!token || !post.id) return;
                  Alert.alert('Delete Video', 'Delete this video?', [
                    { text: 'Cancel', style: 'cancel' },
                    {
                      text: 'Delete',
                      style: 'destructive',
                      onPress: () => void removePost(token, post.id!),
                    },
                  ]);
                }}
              />
            ))
          )}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  content: { paddingBottom: 40 },
  settingsBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: Brand.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerActions: { flexDirection: 'row', gap: 8 },
  headerBadge: {
    position: 'absolute',
    top: -2,
    right: -2,
    minWidth: 16,
    height: 16,
    borderRadius: 8,
    paddingHorizontal: 4,
    backgroundColor: Brand.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerBadgeText: {
    color: Brand.white,
    fontSize: 10,
    fontWeight: '700',
  },
  settingsIcon: { width: 18, height: 18, resizeMode: 'contain' },
  avatarWrap: { alignItems: 'center', marginTop: 10 },
  avatar: {
    width: 96,
    height: 96,
    borderRadius: 48,
    backgroundColor: '#D1D5DB',
  },
  avatarFallback: { alignItems: 'center', justifyContent: 'center' },
  username: {
    textAlign: 'center',
    marginTop: 5,
    fontSize: 15,
    fontWeight: '600',
    color: Brand.textPrimary,
  },
  statsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 4,
  },
  stat: { padding: 16, alignItems: 'center' },
  statNum: { fontSize: 17, color: Brand.textPrimary, fontWeight: '500' },
  statLabel: { fontSize: 13, color: Brand.textLight, marginTop: 2 },
  statDivider: { width: 1, height: 36, backgroundColor: Brand.border },
  actions: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 20,
    marginTop: 4,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'flex-start',
    paddingHorizontal: 4,
    marginTop: 20,
  },
  empty: {
    width: '100%',
    textAlign: 'center',
    marginTop: 24,
    fontSize: 18,
    color: Brand.textPrimary,
  },
});
