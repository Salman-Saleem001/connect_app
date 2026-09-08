/**
 * Flutter `ViewAllStats` — grid of own videos → Stats / Delete.
 */
import { ProfileVideoCard } from '@/components/ProfileVideoCard';
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { Brand } from '@/constants/Colors';
import { openChatMedia } from '@/store/mediaViewerStore';
import { useAuthStore } from '@/store/authStore';
import { useProfileStore } from '@/store/profileStore';
import { router, useFocusEffect } from 'expo-router';
import React, { useCallback } from 'react';
import {
  ActivityIndicator,
  Alert,
  ScrollView,
  StyleSheet,
  Text,
  useWindowDimensions,
  View,
} from 'react-native';

export default function ViewsStatsScreen() {
  const { width } = useWindowDimensions();
  const token = useAuthStore((s) => s.token);
  const posts = useProfileStore((s) => s.posts);
  const loading = useProfileStore((s) => s.loadingPosts);
  const fetched = useProfileStore((s) => s.postsFetched);
  const fetchMyPosts = useProfileStore((s) => s.fetchMyPosts);
  const removePost = useProfileStore((s) => s.removePost);

  useFocusEffect(
    useCallback(() => {
      if (token) void fetchMyPosts(token);
    }, [token, fetchMyPosts]),
  );

  const cardWidth = width / 2.5;
  const cardHeight = (width / 3) * 1.5;

  return (
    <View style={styles.root}>
      <ScreenAppBar title="Views Stats" />
      <ScrollView contentContainerStyle={styles.content}>
        {loading && !fetched ? (
          <ActivityIndicator color={Brand.primary} style={{ marginTop: 24 }} />
        ) : fetched && posts.length === 0 ? (
          <Text style={styles.empty}>No Stats available</Text>
        ) : (
          <View style={styles.grid}>
            {posts.map((post, index) => (
              <ProfileVideoCard
                key={post.id ?? index}
                thumbnail={post.thumbnail}
                width={cardWidth}
                height={cardHeight}
                onOpen={() => {
                  if (!post.video) return;
                  openChatMedia(post.video);
                  router.push('/chat/video');
                }}
                onFollowRequests={() => {
                  router.push({
                    pathname: '/profile/follow-requests',
                    params: {
                      videoId: String(post.id ?? 0),
                      thumbnail: post.thumbnail ?? '',
                      name: post.title ?? '',
                      viewsCount: String(post.views_count ?? 0),
                    },
                  });
                }}
                onStats={() => router.push(`/profile/stats/${post.id ?? 0}`)}
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
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  content: { paddingHorizontal: 10, paddingBottom: 40 },
  grid: { flexDirection: 'row', flexWrap: 'wrap' },
  empty: {
    textAlign: 'center',
    marginTop: 40,
    fontSize: 18,
    color: Brand.textPrimary,
  },
});
