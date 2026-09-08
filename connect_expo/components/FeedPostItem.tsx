import { AppTourTarget } from '@/components/AppTourTarget';
import { FeedVideo } from '@/components/FeedVideo';
import { Brand } from '@/constants/Colors';
import { useAuthStore } from '@/store/authStore';
import { useFeedStore } from '@/store/feedStore';
import {
  stripMediaEditsFromInfo,
  useMediaOverlayStore,
} from '@/store/mediaViewerStore';
import type { Post } from '@/types/posts';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import * as Sharing from 'expo-sharing';
import { router } from 'expo-router';
import React, { useEffect, useMemo } from 'react';
import {
  ActionSheetIOS,
  Alert,
  Image,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';

type Props = {
  post: Post;
  isActive: boolean;
  pageHeight: number;
};

export function FeedPostItem({ post, isActive, pageHeight }: Props) {
  const token = useAuthStore((s) => s.token);
  const userId = useAuthStore((s) => s.user?.id);
  const toggleLike = useFeedStore((s) => s.toggleLike);
  const removePost = useFeedStore((s) => s.removePost);

  const { info: displayInfo, edits: infoEdits } = useMemo(
    () => stripMediaEditsFromInfo(post.info),
    [post.info],
  );

  useEffect(() => {
    if (post.video && infoEdits) {
      useMediaOverlayStore.getState().remember(post.video, infoEdits);
    }
  }, [post.video, infoEdits]);

  const liked = post.isLiked ?? false;
  const isOwn = post.user_id === userId;

  async function onShare() {
    if (!post.video) return;
    try {
      const available = await Sharing.isAvailableAsync();
      if (available) {
        await Sharing.shareAsync(post.video);
      } else {
        Alert.alert('Share', post.video);
      }
    } catch {
      Alert.alert('Share', post.video);
    }
  }

  function onMore() {
    const options = ['Report', 'Block', 'Cancel'];
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        { options, destructiveButtonIndex: 0, cancelButtonIndex: 2, title: 'Actions' },
        (i) => {
          if (i === 0 || i === 1) {
            if (post.id) removePost(post.id);
            Alert.alert(i === 0 ? 'Reported' : 'Blocked', 'Action sent.');
          }
        },
      );
    } else {
      Alert.alert('Actions', undefined, [
        {
          text: 'Report',
          style: 'destructive',
          onPress: () => {
            if (post.id) removePost(post.id);
          },
        },
        {
          text: 'Block',
          style: 'destructive',
          onPress: () => {
            if (post.id) removePost(post.id);
          },
        },
        { text: 'Cancel', style: 'cancel' },
      ]);
    }
  }

  return (
    <View style={[styles.page, { height: pageHeight }]}>
      <FeedVideo uri={post.video} isActive={isActive} edits={infoEdits} />

      {/* Flutter: Positioned(top: 252, left: 10) */}
      <View style={styles.leftActions}>
        <View style={styles.sideLogoWrap}>
          <Image
            source={require('../assets/images/kora_logo.png')}
            style={styles.sideLogo}
            resizeMode="cover"
          />
        </View>
        <View style={{ height: 20 }} />

        {/* Flutter: icon in GestureDetector, label as sibling below */}
        <View style={styles.actionCenter}>
          <AppTourTarget id="like" active={isActive}>
            <Pressable
              onPress={() => {
                if (token && post.id) toggleLike(token, post.id);
              }}
            >
              <Image
                source={require('../assets/images/ic_heart.png')}
                style={[styles.heart, { tintColor: liked ? '#FF0000' : '#FFFFFF' }]}
              />
            </Pressable>
          </AppTourTarget>
          <Text style={styles.actionLabel}>{post.likes_count ?? 0} Likes</Text>
        </View>
        <View style={{ height: 20 }} />

        {/* Opens chat with the video uploader (Flutter ChatDetailScreenNew) */}
        <AppTourTarget id="connect" active={isActive}>
          <Pressable
            style={styles.actionCenter}
            disabled={isOwn}
            onPress={() => {
              if (isOwn) return;
              const videoId = post.id;
              const otherUserId = post.user_id ?? post.user?.id;
              if (!videoId || !otherUserId) {
                Alert.alert('Error', 'Missing video or user id from backend.');
                return;
              }
              router.push({
                pathname: '/chat/[videoId]',
                params: {
                  videoId: String(videoId),
                  secondUserId: String(otherUserId),
                  userName: (
                    post.user?.first_name ||
                    post.user?.username ||
                    ''
                  ).toLowerCase(),
                  description: displayInfo,
                  userAvatar: post.user?.avatar ?? '',
                  bio: post.user?.bio ?? '',
                  tags: [...new Set(post.tags ?? [])].join(','),
                },
              });
            }}
          >
            <Image
              source={require('../assets/images/ic_comments.png')}
              style={[styles.comment, isOwn && { opacity: 0.4 }]}
            />
            <Text style={styles.actionLabel}>Connect</Text>
          </Pressable>
        </AppTourTarget>
        <View style={{ height: 20 }} />

        <View style={styles.actionCenter}>
          <AppTourTarget id="share" active={isActive}>
            <Pressable onPress={onShare}>
              <Image
                source={require('../assets/images/ic_share.png')}
                style={styles.share}
              />
            </Pressable>
          </AppTourTarget>
          <Text style={styles.actionLabel}>Share</Text>
        </View>
        <View style={{ height: 20 }} />

        <AppTourTarget id="more" active={isActive}>
          <Pressable onPress={onMore} hitSlop={8}>
            <MaterialIcons name="more-horiz" size={32} color="#FFFFFF" />
          </Pressable>
        </AppTourTarget>
        <View style={{ height: 10 }} />
      </View>

      {/* Flutter: Positioned(bottom: 20, left: 11, right: 70) */}
      <View style={styles.userInfo}>
        <Pressable>
          {post.user?.avatar ? (
            <Image
              source={{ uri: post.user.avatar }}
              style={styles.avatar}
              resizeMode="cover"
            />
          ) : (
            <MaterialIcons
              name="account-circle"
              size={50}
              color="#9E9E9E"
              style={styles.avatarFallback}
            />
          )}
          <View style={{ height: 10 }} />
          <Text style={styles.handle}>
            @{(post.user?.first_name ?? '').toLowerCase()}
          </Text>
        </Pressable>

        <View style={{ height: 10 }} />

        {displayInfo ? (
          <Text style={styles.info}>{displayInfo}</Text>
        ) : null}

        {post.id != null ? (
          <View style={styles.titleRow}>
            <MaterialIcons name="videocam" size={18} color="#FFFFFF" />
            <View style={{ width: 8 }} />
            <Text style={styles.titleText}>{post.title ?? ''}</Text>
          </View>
        ) : null}

        <View style={{ height: 30 }} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  page: {
    width: '100%',
    backgroundColor: '#000',
  },
  leftActions: {
    position: 'absolute',
    left: 10,
    top: 252,
    alignItems: 'center',
    zIndex: 2,
  },
  sideLogoWrap: {
    borderRadius: 100,
    overflow: 'hidden',
  },
  sideLogo: {
    width: 49,
    height: 49,
  },
  actionCenter: {
    alignItems: 'center',
  },
  heart: {
    width: 40,
    height: 40,
    resizeMode: 'contain',
  },
  comment: {
    width: 34,
    height: 34,
    resizeMode: 'contain',
    tintColor: '#FFFFFF',
  },
  share: {
    width: 25,
    height: 25,
    resizeMode: 'contain',
    tintColor: '#FFFFFF',
  },
  actionLabel: {
    color: '#FFFFFF',
    fontSize: 14,
  },
  userInfo: {
    position: 'absolute',
    left: 11,
    right: 70,
    bottom: 20,
    zIndex: 2,
  },
  avatar: {
    width: 50,
    height: 50,
    borderRadius: 50,
  },
  avatarFallback: {
    marginBottom: 0,
  },
  handle: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '600',
  },
  info: {
    color: '#FFFFFF',
    fontSize: 12,
    width: 200,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  titleText: {
    color: '#FFFFFF',
    fontSize: 12,
  },
});
