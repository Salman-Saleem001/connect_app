/**
 * Flutter `StatusView` — full-screen story playback with progress + tap zones.
 * Video waits for readyToPlay / first frame before progress advances (avoids
 * black screen + audio-only in fullScreenModal).
 */
import { Brand } from '@/constants/Colors';
import { viewStory } from '@/services/api/posts';
import { useAuthStore } from '@/store/authStore';
import { useStoriesStore } from '@/store/storiesStore';
import type { StoryItem } from '@/types/stories';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { setAudioModeAsync } from 'expo-audio';
import { useVideoPlayer, VideoView } from 'expo-video';
import { router } from 'expo-router';
import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Image,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

function formatStoryTime(createdAt?: string | null) {
  if (!createdAt) return '';
  const d = new Date(createdAt);
  if (Number.isNaN(d.getTime())) return '';
  const diffMs = Date.now() - d.getTime();
  const hours = Math.floor(diffMs / 3600000);
  if (hours < 1) {
    const mins = Math.max(1, Math.floor(diffMs / 60000));
    return `${mins}m ago`;
  }
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

function isStoryVideo(story: StoryItem) {
  const type = String(story.media_type ?? '').toLowerCase();
  if (type === 'video' || type.startsWith('video/')) return true;
  if (type === 'image' || type.startsWith('image/')) return false;
  const url = String(story.media ?? '').toLowerCase().split('?')[0];
  return /\.(mp4|mov|m4v|webm|avi)($)/i.test(url);
}

function StoryMedia({
  story,
  onReady,
  onEnded,
  paused,
}: {
  story: StoryItem;
  onReady: (durationMs: number) => void;
  onEnded: () => void;
  paused: boolean;
}) {
  const isVideo = isStoryVideo(story);
  const url = (story.media ?? '').trim();
  const thumb = (story.thumbnail ?? '').trim();
  const readySent = useRef(false);
  const endedSent = useRef(false);
  const [hasFrame, setHasFrame] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);

  // Don't autoplay in setup — wait until surface is ready (fixes audio-only black screen)
  const player = useVideoPlayer(isVideo && url ? url : null, (p) => {
    p.loop = false;
    p.muted = false;
    p.volume = 1;
    p.timeUpdateEventInterval = 0.25;
  });

  useEffect(() => {
    void (async () => {
      try {
        await setAudioModeAsync({
          playsInSilentMode: true,
          interruptionMode: 'duckOthers',
          allowsRecording: false,
        });
      } catch {
        // ignore
      }
    })();
  }, []);

  useEffect(() => {
    readySent.current = false;
    endedSent.current = false;
    setHasFrame(false);
    setLoadError(null);
  }, [url, isVideo]);

  const markReady = useCallback(
    (durationMs: number) => {
      if (readySent.current) return;
      readySent.current = true;
      onReady(Math.max(2000, durationMs));
    },
    [onReady],
  );

  useEffect(() => {
    if (!isVideo || !url) {
      markReady(5000);
      return;
    }

    let cancelled = false;

    const tryPlay = () => {
      if (cancelled || paused) return;
      try {
        player.muted = false;
        player.volume = 1;
        player.play();
      } catch {
        // ignore
      }
    };

    const onStatus = ({
      status,
      error,
    }: {
      status: string;
      error?: { message?: string };
    }) => {
      if (cancelled) return;
      if (status === 'error') {
        setLoadError(error?.message || 'Unable to play video');
        markReady(5000);
        return;
      }
      if (status === 'readyToPlay') {
        const dur = player.duration ?? 0;
        if (dur > 0.2) markReady(dur * 1000);
        tryPlay();
      }
    };

    const onEnd = () => {
      if (cancelled || endedSent.current) return;
      endedSent.current = true;
      onEnded();
    };

    const statusSub = player.addListener('statusChange', onStatus);
    const endSub = player.addListener('playToEnd', onEnd);

    // If already ready when remounting
    if (player.status === 'readyToPlay') {
      const dur = player.duration ?? 0;
      if (dur > 0.2) markReady(dur * 1000);
      tryPlay();
    }

    // Duration sometimes arrives after readyToPlay
    const durPoll = setInterval(() => {
      if (cancelled || readySent.current) return;
      const dur = player.duration ?? 0;
      if (player.status === 'readyToPlay' && dur > 0.2) {
        markReady(dur * 1000);
        tryPlay();
      }
    }, 250);

    // Don't advance forever if metadata never arrives — still wait a bit for frames
    const readyFallback = setTimeout(() => {
      if (cancelled || readySent.current) return;
      markReady(15000);
      tryPlay();
    }, 8000);

    return () => {
      cancelled = true;
      statusSub.remove();
      endSub.remove();
      clearInterval(durPoll);
      clearTimeout(readyFallback);
      try {
        player.pause();
      } catch {
        // ignore
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isVideo, url, player]);

  useEffect(() => {
    if (!isVideo || !url) return;
    try {
      player.muted = false;
      player.volume = 1;
      if (paused) player.pause();
      else if (player.status === 'readyToPlay' || hasFrame) player.play();
    } catch {
      // ignore
    }
  }, [paused, player, isVideo, url, hasFrame]);

  if (!url) {
    return (
      <View style={styles.center}>
        <Text style={styles.muted}>No media</Text>
      </View>
    );
  }

  if (isVideo) {
    const showCover = !hasFrame;
    return (
      <View style={styles.mediaFill}>
        {thumb && /^https?:\/\//i.test(thumb) ? (
          <Image
            source={{ uri: thumb }}
            style={StyleSheet.absoluteFill}
            resizeMode="cover"
          />
        ) : null}
        <VideoView
          style={StyleSheet.absoluteFill}
          player={player}
          contentFit="cover"
          nativeControls={false}
          allowsVideoFrameAnalysis={false}
          fullscreenOptions={{ enable: false }}
          {...(Platform.OS === 'android'
            ? { surfaceType: 'textureView' as const, useExoShutter: false }
            : {})}
          onFirstFrameRender={() => {
            setHasFrame(true);
            const dur = player.duration ?? 0;
            if (dur > 0.2) markReady(dur * 1000);
            else if (!readySent.current) markReady(15000);
          }}
        />
        {showCover ? (
          <View style={styles.loadingOverlay} pointerEvents="none">
            <ActivityIndicator color={Brand.white} size="large" />
            <Text style={styles.loadingHint}>Loading video…</Text>
          </View>
        ) : null}
        {loadError ? (
          <View style={styles.loadingOverlay}>
            <Text style={styles.muted}>{loadError}</Text>
          </View>
        ) : null}
      </View>
    );
  }

  return (
    <Image
      source={{ uri: url }}
      style={styles.mediaImage}
      resizeMode="contain"
      onLoad={() => markReady(5000)}
    />
  );
}

export default function StoryStatusScreen() {
  const insets = useSafeAreaInsets();
  const token = useAuthStore((s) => s.token);
  const me = useAuthStore((s) => s.user);
  const statuses = useStoriesStore((s) => s.viewerStatuses);
  const startIndex = useStoriesStore((s) => s.viewerIndex);
  const markViewed = useStoriesStore((s) => s.markViewed);
  const clearViewer = useStoriesStore((s) => s.clearViewer);

  const [index, setIndex] = useState(startIndex);
  const [progress, setProgress] = useState(0);
  const [durationMs, setDurationMs] = useState(5000);
  const [mediaReady, setMediaReady] = useState(false);
  const [paused, setPaused] = useState(false);
  const [mediaKey, setMediaKey] = useState(0);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const reportedRef = useRef<Set<number>>(new Set());
  const advancingRef = useRef(false);
  const closingRef = useRef(false);

  const leaveScreen = useCallback(() => {
    if (closingRef.current) return;
    closingRef.current = true;
    clearViewer();
    try {
      if (router.canDismiss()) {
        router.dismiss();
        return;
      }
    } catch {
      // ignore
    }
    try {
      if (router.canGoBack()) {
        router.back();
        return;
      }
    } catch {
      // ignore
    }
    router.replace('/chats');
  }, [clearViewer]);

  const reportView = useCallback(
    (story: StoryItem) => {
      if (!token || reportedRef.current.has(story.id)) return;
      reportedRef.current.add(story.id);
      const isSelf =
        story.user?.id != null && me?.id != null && story.user.id === me.id;
      markViewed(story.id, isSelf);
      void viewStory(token, story.id);
    },
    [token, me?.id, markViewed],
  );

  const goNext = useCallback(() => {
    if (advancingRef.current || closingRef.current) return;
    advancingRef.current = true;
    setProgress(0);
    setMediaReady(false);
    setPaused(false);
    if (index < statuses.length - 1) {
      setIndex((i) => i + 1);
      setMediaKey((k) => k + 1);
      setTimeout(() => {
        advancingRef.current = false;
      }, 300);
      return;
    }
    leaveScreen();
  }, [index, statuses.length, leaveScreen]);

  const goPrev = useCallback(() => {
    setProgress(0);
    setMediaReady(false);
    setPaused(false);
    if (index > 0) {
      setIndex((i) => i - 1);
      setMediaKey((k) => k + 1);
    }
  }, [index]);

  useEffect(() => {
    if (!statuses.length && !closingRef.current) {
      leaveScreen();
    }
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (!statuses.length || closingRef.current) return;
    const story = statuses[index];
    if (story) reportView(story);
  }, [statuses, index, reportView]);

  // Progress only after media is ready (Flutter waits for video initialize)
  useEffect(() => {
    if (timerRef.current) clearInterval(timerRef.current);
    if (!mediaReady || paused || !statuses.length || closingRef.current) return;
    const step = 50;
    timerRef.current = setInterval(() => {
      setProgress((p) => {
        const next = p + step / Math.max(durationMs, 1);
        if (next >= 1) {
          if (timerRef.current) clearInterval(timerRef.current);
          goNext();
          return 0;
        }
        return next;
      });
    }, step);
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [durationMs, paused, mediaReady, index, mediaKey, statuses.length, goNext]);

  if (!statuses.length) {
    return (
      <View style={[styles.root, styles.center]}>
        <ActivityIndicator color={Brand.white} />
      </View>
    );
  }

  const story = statuses[index];
  if (!story) {
    return (
      <View style={[styles.root, styles.center]}>
        <ActivityIndicator color={Brand.white} />
      </View>
    );
  }

  const displayName =
    story.user?.first_name ||
    story.user?.username ||
    story.user?.name ||
    'User';
  const avatar = story.user?.avatar;

  return (
    <View style={styles.root}>
      <StoryMedia
        key={`${story.id}-${mediaKey}`}
        story={story}
        paused={paused}
        onReady={(ms) => {
          setDurationMs(Math.max(2000, ms));
          setProgress(0);
          setMediaReady(true);
        }}
        onEnded={goNext}
      />

      <View
        style={[styles.topChrome, { paddingTop: insets.top + 8 }]}
        pointerEvents="box-none"
      >
        <View style={styles.progressRow}>
          {statuses.map((s, i) => (
            <View key={`${s.id}-${i}`} style={styles.progressTrack}>
              <View
                style={[
                  styles.progressFill,
                  {
                    width:
                      i < index
                        ? '100%'
                        : i === index
                          ? `${Math.min(100, progress * 100)}%`
                          : '0%',
                  },
                ]}
              />
            </View>
          ))}
        </View>

        <View style={styles.header}>
          <Image
            source={
              avatar && /^https?:\/\//i.test(avatar)
                ? { uri: avatar }
                : require('../../assets/images/ic_person.png')
            }
            style={styles.avatar}
          />
          <View style={styles.headerText}>
            <Text style={styles.name}>{displayName}</Text>
            <Text style={styles.time}>{formatStoryTime(story.created_at)}</Text>
          </View>
          <Pressable onPress={leaveScreen} hitSlop={12}>
            <MaterialIcons name="close" size={26} color={Brand.white} />
          </Pressable>
        </View>
      </View>

      <View style={styles.tapRow} pointerEvents="box-none">
        <Pressable
          style={styles.tapHalf}
          onPress={goPrev}
          onLongPress={() => setPaused(true)}
          onPressOut={() => setPaused(false)}
          delayLongPress={200}
        />
        <Pressable
          style={styles.tapHalf}
          onPress={goNext}
          onLongPress={() => setPaused(true)}
          onPressOut={() => setPaused(false)}
          delayLongPress={200}
        />
      </View>

      {story.caption ? (
        <View style={[styles.captionWrap, { paddingBottom: insets.bottom + 24 }]}>
          <Text style={styles.caption}>{story.caption}</Text>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: Brand.scaffoldDark,
  },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  muted: { color: Brand.txtGrey, textAlign: 'center', paddingHorizontal: 24 },
  mediaFill: { ...StyleSheet.absoluteFill, backgroundColor: '#000' },
  mediaImage: { ...StyleSheet.absoluteFill, width: '100%', height: '100%' },
  loadingOverlay: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0,0,0,0.35)',
  },
  loadingHint: {
    color: 'rgba(255,255,255,0.9)',
    marginTop: 12,
    fontSize: 14,
  },
  topChrome: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 2,
    paddingHorizontal: 10,
  },
  progressRow: {
    flexDirection: 'row',
    gap: 4,
    height: 3,
  },
  progressTrack: {
    flex: 1,
    height: 3,
    borderRadius: 2,
    backgroundColor: 'rgba(255,255,255,0.25)',
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Brand.primary,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 12,
    gap: 10,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Brand.bgGrey,
  },
  headerText: { flex: 1 },
  name: { color: Brand.white, fontWeight: '600', fontSize: 14 },
  time: { color: 'rgba(255,255,255,0.85)', fontSize: 12, marginTop: 2 },
  tapRow: {
    ...StyleSheet.absoluteFill,
    flexDirection: 'row',
    zIndex: 1,
  },
  tapHalf: { flex: 1 },
  captionWrap: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 2,
    paddingHorizontal: 16,
    paddingTop: 40,
    backgroundColor: 'rgba(0,0,0,0.35)',
  },
  caption: { color: Brand.white, fontSize: 15, lineHeight: 22 },
});
