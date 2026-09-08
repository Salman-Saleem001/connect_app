/**
 * Flutter/Instagram-style chats stories strip:
 * - First ring = My Story (+ add)
 * - Then other people's stories from API `feed` (grouped per user)
 * - Upload shows a progress ring like Instagram
 */
import { Brand } from '@/constants/Colors';
import { getStories } from '@/services/api/posts';
import { useAuthStore } from '@/store/authStore';
import { useStoriesStore } from '@/store/storiesStore';
import {
  groupFeedStories,
  type StoryItem,
} from '@/types/stories';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router, useFocusEffect } from 'expo-router';
import React, { useCallback, useEffect, useMemo, useRef } from 'react';
import {
  ActivityIndicator,
  Animated,
  Easing,
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

const ROW_HEIGHT = 92;
const MY_SIZE = 52;
const FEED_SIZE = 48;
const TICKS = 28;

function UploadProgressRing({
  size,
  progress,
}: {
  size: number;
  progress: number;
}) {
  const spin = useRef(new Animated.Value(0)).current;
  const ring = size + 8;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.timing(spin, {
        toValue: 1,
        duration: 1100,
        easing: Easing.linear,
        useNativeDriver: true,
      }),
    );
    loop.start();
    return () => loop.stop();
  }, [spin]);

  const rotate = spin.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  const filled = Math.max(0.08, Math.min(1, progress));

  return (
    <Animated.View
      pointerEvents="none"
      style={[
        styles.uploadRing,
        {
          width: ring,
          height: ring,
          borderRadius: ring / 2,
          transform: [{ rotate }],
        },
      ]}
    >
      {Array.from({ length: TICKS }).map((_, i) => {
        const on = i / TICKS <= filled;
        return (
          <View
            key={i}
            style={[
              styles.uploadTickWrap,
              {
                width: ring,
                height: ring,
                transform: [{ rotate: `${(i / TICKS) * 360}deg` }],
              },
            ]}
          >
            <View
              style={[
                styles.uploadTick,
                { backgroundColor: on ? Brand.primary : 'rgba(0,0,0,0.12)' },
              ]}
            />
          </View>
        );
      })}
    </Animated.View>
  );
}

function GradientRing({
  showBorder,
  children,
  size,
}: {
  showBorder: boolean;
  children: React.ReactNode;
  size: number;
}) {
  const outer = size + 6;
  const inner = size + 2;
  return (
    <View
      style={[
        styles.ringOuter,
        {
          width: outer,
          height: outer,
          borderRadius: outer / 2,
        },
        showBorder ? styles.ringGradient : styles.ringPlain,
      ]}
    >
      <View
        style={[
          styles.ringInner,
          {
            width: inner,
            height: inner,
            borderRadius: inner / 2,
          },
        ]}
      >
        {children}
      </View>
    </View>
  );
}

function StoryAvatar({ uri, size }: { uri?: string | null; size: number }) {
  const raw = uri ? String(uri).trim() : '';
  const usable =
    !!raw &&
    (/^https?:\/\//i.test(raw) ||
      raw.startsWith('file://') ||
      raw.startsWith('content://') ||
      raw.startsWith('/'));
  const sourceUri =
    usable && raw.startsWith('/') && !raw.startsWith('file://')
      ? `file://${raw}`
      : raw;
  return (
    <Image
      source={
        usable ? { uri: sourceUri } : require('../assets/images/ic_person.png')
      }
      style={{ width: size, height: size, borderRadius: size / 2 }}
    />
  );
}

function openStatus(statuses: StoryItem[], initialIndex = 0) {
  if (!statuses.length) return;
  useStoriesStore.getState().openViewer(statuses, initialIndex);
  router.push('/chat/status');
}

export function ChatStoriesRow() {
  const token = useAuthStore((s) => s.token);
  const me = useAuthStore((s) => s.user);
  const payload = useStoriesStore((s) => s.payload);
  const loading = useStoriesStore((s) => s.loading);
  const uploading = useStoriesStore((s) => s.uploading);
  const uploadProgress = useStoriesStore((s) => s.uploadProgress);
  const uploadPreviewUri = useStoriesStore((s) => s.uploadPreviewUri);
  const setPayload = useStoriesStore((s) => s.setPayload);
  const setLoading = useStoriesStore((s) => s.setLoading);

  const refresh = useCallback(async () => {
    if (!token) {
      setPayload({ my_stories: [], feed: [] });
      setLoading(false);
      return;
    }
    const hasData =
      useStoriesStore.getState().payload.my_stories.length > 0 ||
      useStoriesStore.getState().payload.feed.length > 0;
    if (!hasData) setLoading(true);
    try {
      const data = await getStories(token);
      setPayload(data);
    } catch {
      if (!hasData) setPayload({ my_stories: [], feed: [] });
    } finally {
      setLoading(false);
    }
  }, [token, setPayload, setLoading]);

  useFocusEffect(
    useCallback(() => {
      void refresh();
    }, [refresh]),
  );

  const myStories = payload.my_stories;
  const feedGroups = useMemo(
    () => groupFeedStories(payload.feed),
    [payload.feed],
  );
  const myHasUnviewed = myStories.some((s) => !s.is_viewed);
  const hasMyStory = myStories.length > 0;
  const myLabel = uploading ? 'Sending…' : hasMyStory ? 'My Story' : 'Your story';

  function onAddStory() {
    router.push({
      pathname: '/chat/camera',
      params: { fromStory: '1' },
    });
  }

  function onMyStory() {
    if (uploading) return;
    if (myStories.length === 0) {
      onAddStory();
      return;
    }
    openStatus(myStories, 0);
  }

  function onFeedGroup(stories: StoryItem[]) {
    openStatus(stories, 0);
  }

  return (
    <View style={styles.shell}>
      {loading && myStories.length === 0 && feedGroups.length === 0 && !uploading ? (
        <View style={styles.loadingWrap}>
          <ActivityIndicator color={Brand.primary} />
        </View>
      ) : (
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          style={styles.scroll}
          contentContainerStyle={styles.row}
        >
          <View style={styles.myColumn}>
            <View style={styles.myWrap}>
              {uploading ? (
                <UploadProgressRing size={MY_SIZE} progress={uploadProgress} />
              ) : (
                <GradientRing
                  showBorder={hasMyStory && myHasUnviewed}
                  size={MY_SIZE}
                >
                  <Pressable onPress={onMyStory}>
                    <StoryAvatar
                      uri={uploadPreviewUri || me?.avatar}
                      size={MY_SIZE}
                    />
                  </Pressable>
                </GradientRing>
              )}
              {uploading ? (
                <View style={styles.myAvatarUnderRing}>
                  <StoryAvatar
                    uri={uploadPreviewUri || me?.avatar}
                    size={MY_SIZE}
                  />
                </View>
              ) : null}
              {!uploading ? (
                <Pressable style={styles.addBtn} onPress={onAddStory} hitSlop={6}>
                  <MaterialIcons name="add" size={16} color={Brand.white} />
                </Pressable>
              ) : null}
            </View>
            <Text style={styles.label} numberOfLines={1}>
              {myLabel}
            </Text>
          </View>

          {feedGroups.map((group) => (
            <Pressable
              key={group.key}
              style={styles.feedColumn}
              onPress={() => onFeedGroup(group.stories)}
            >
              <GradientRing showBorder={group.hasUnviewed} size={FEED_SIZE}>
                <StoryAvatar uri={group.avatar} size={FEED_SIZE} />
              </GradientRing>
              <Text style={styles.label} numberOfLines={1}>
                {group.name}
              </Text>
            </Pressable>
          ))}
        </ScrollView>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  shell: {
    height: ROW_HEIGHT,
    marginTop: 4,
    marginBottom: 0,
    justifyContent: 'center',
  },
  scroll: {
    flexGrow: 0,
    height: ROW_HEIGHT,
  },
  row: {
    alignItems: 'flex-start',
    height: ROW_HEIGHT,
    paddingHorizontal: 2,
    paddingTop: 2,
    gap: 10,
  },
  loadingWrap: {
    height: ROW_HEIGHT,
    alignItems: 'center',
    justifyContent: 'center',
  },
  myColumn: {
    width: MY_SIZE + 14,
    alignItems: 'center',
    marginRight: 2,
  },
  myWrap: {
    width: MY_SIZE + 10,
    height: MY_SIZE + 10,
    position: 'relative',
    alignItems: 'center',
    justifyContent: 'center',
  },
  myAvatarUnderRing: {
    position: 'absolute',
    width: MY_SIZE,
    height: MY_SIZE,
    borderRadius: MY_SIZE / 2,
    overflow: 'hidden',
  },
  feedColumn: {
    width: FEED_SIZE + 14,
    alignItems: 'center',
  },
  label: {
    marginTop: 4,
    fontSize: 11,
    color: Brand.textPrimary,
    maxWidth: FEED_SIZE + 18,
    textAlign: 'center',
  },
  uploadRing: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 2,
  },
  uploadTickWrap: {
    position: 'absolute',
    alignItems: 'center',
  },
  uploadTick: {
    width: 2.5,
    height: 5,
    borderRadius: 1,
    marginTop: 1,
  },
  ringOuter: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  ringGradient: {
    borderWidth: 2,
    borderColor: Brand.primary,
  },
  ringPlain: {
    borderWidth: 2,
    borderColor: 'rgba(0,0,0,0.12)',
  },
  ringInner: {
    backgroundColor: Brand.white,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  addBtn: {
    position: 'absolute',
    right: -1,
    bottom: -1,
    width: 22,
    height: 22,
    borderRadius: 11,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Brand.primary,
    borderWidth: 2,
    borderColor: Brand.white,
    zIndex: 2,
  },
});
