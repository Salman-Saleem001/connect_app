import { MediaEditsOverlay } from '@/components/MediaEditsOverlay';
import { Brand } from '@/constants/Colors';
import {
  useMediaOverlayStore,
  useMediaViewerStore,
} from '@/store/mediaViewerStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { setAudioModeAsync, useAudioPlayer } from 'expo-audio';
import { useVideoPlayer, VideoView } from 'expo-video';
import { router } from 'expo-router';
import React, { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Image,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
  useWindowDimensions,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const AUDIO_SOURCES: Record<string, number> = {
  distant: require('../../assets/audio/distant.mp3'),
  stock: require('../../assets/audio/stock.mp3'),
  sunlit: require('../../assets/audio/sunlit.mp3'),
};

export default function ChatVideoScreen() {
  const insets = useSafeAreaInsets();
  const { width, height } = useWindowDimensions();
  const url = useMediaViewerStore((s) => s.url);
  const showImage = useMediaViewerStore((s) => s.isImage);
  const storeEdits = useMediaViewerStore((s) => s.edits);
  const cachedEdits = useMediaOverlayStore((s) =>
    url ? s.byUrl[url.trim()] : undefined,
  );
  const edits = storeEdits ?? cachedEdits ?? null;
  const clear = useMediaViewerStore((s) => s.clear);
  const [error, setError] = useState<string | null>(null);
  const [ready, setReady] = useState(false);

  const player = useVideoPlayer(url && !showImage ? url : null, (p) => {
    p.loop = true;
    p.play();
  });
  const musicPlayer = useAudioPlayer(null);

  useEffect(() => {
    setError(null);
    setReady(false);
    if (!url || showImage) return;

    try {
      player.play();
      setReady(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unable to play video');
    }

    return () => {
      try {
        player.pause();
      } catch {
        // ignore
      }
    };
  }, [url, showImage, player]);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      const id = edits?.audioId;
      if (!id || !AUDIO_SOURCES[id]) {
        try {
          musicPlayer.pause();
        } catch {
          // ignore
        }
        return;
      }
      try {
        await setAudioModeAsync({
          playsInSilentMode: true,
          interruptionMode: 'mixWithOthers',
        });
        if (cancelled) return;
        musicPlayer.replace(AUDIO_SOURCES[id]);
        musicPlayer.loop = true;
        await musicPlayer.seekTo(0);
        musicPlayer.play();
      } catch {
        // Music is optional
      }
    })();
    return () => {
      cancelled = true;
      try {
        musicPlayer.pause();
      } catch {
        // ignore
      }
    };
  }, [edits?.audioId, musicPlayer]);

  function onBack() {
    try {
      player.pause();
    } catch {
      // ignore
    }
    try {
      musicPlayer.pause();
    } catch {
      // ignore
    }
    clear();
    if (router.canDismiss()) router.dismiss();
    else if (router.canGoBack()) router.back();
    else router.replace('/chats');
  }

  return (
    <View style={styles.root}>
      {url && showImage ? (
        <Image source={{ uri: url }} style={StyleSheet.absoluteFill} resizeMode="contain" />
      ) : url ? (
        <>
          <VideoView
            player={player}
            style={StyleSheet.absoluteFill}
            contentFit="contain"
            nativeControls={false}
            fullscreenOptions={{ enable: false }}
            {...(Platform.OS === 'android'
              ? { surfaceType: 'textureView' as const }
              : {})}
          />
          {!ready && !error ? (
            <View style={styles.center} pointerEvents="none">
              <ActivityIndicator color={Brand.white} size="large" />
              <Text style={styles.hint}>Loading video…</Text>
            </View>
          ) : null}
          {error ? (
            <View style={styles.center}>
              <Text style={styles.error}>{error}</Text>
            </View>
          ) : null}
        </>
      ) : (
        <View style={styles.center}>
          <Text style={styles.error}>No media URL. Go back and open the video again.</Text>
        </View>
      )}

      <MediaEditsOverlay edits={edits} layoutWidth={width} layoutHeight={height} />

      <Pressable style={[styles.back, { top: insets.top + 20 }]} onPress={onBack} hitSlop={12}>
        <MaterialIcons name="arrow-back-ios" size={28} color={Brand.white} />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#000' },
  center: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  hint: { color: Brand.white, marginTop: 12, fontSize: 14 },
  error: { color: Brand.white, textAlign: 'center', fontSize: 14 },
  back: {
    position: 'absolute',
    left: 20,
    zIndex: 30,
    elevation: 30,
    backgroundColor: Brand.primaryBottom,
    borderRadius: 10,
    paddingVertical: 8,
    paddingLeft: 12,
    paddingRight: 4,
  },
});
