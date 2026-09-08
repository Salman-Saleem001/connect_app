import { MediaEditsOverlay } from '@/components/MediaEditsOverlay';
import type { MediaEdits } from '@/store/mediaViewerStore';
import { useMediaOverlayStore } from '@/store/mediaViewerStore';
import { useVideoPlayer, VideoView } from 'expo-video';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import React, { useEffect, useState } from 'react';
import { Platform, Pressable, StyleSheet, View } from 'react-native';

type Props = {
  uri?: string;
  isActive: boolean;
  edits?: MediaEdits | null;
};

export function FeedVideo({ uri, isActive, edits }: Props) {
  const [userPaused, setUserPaused] = useState(false);
  const cached = useMediaOverlayStore((s) => (uri ? s.byUrl[uri.trim()] : undefined));
  const overlay = edits ?? cached ?? null;

  const player = useVideoPlayer(uri ?? null, (p) => {
    p.loop = true;
    p.muted = false;
  });

  useEffect(() => {
    if (isActive) {
      setUserPaused(false);
    }
  }, [isActive, uri]);

  useEffect(() => {
    if (!uri) return;
    try {
      if (isActive && !userPaused) {
        player.play();
      } else {
        player.pause();
        if (!isActive) {
          player.currentTime = 0;
        }
      }
    } catch {
      // ignore race on unmount
    }
  }, [isActive, userPaused, uri, player]);

  function togglePlayPause() {
    if (!isActive || !uri) return;
    setUserPaused((paused) => !paused);
  }

  if (!uri) {
    return <View style={styles.black} />;
  }

  return (
    <View style={styles.black}>
      <VideoView
        player={player}
        style={StyleSheet.absoluteFill}
        contentFit="cover"
        nativeControls={false}
        fullscreenOptions={{ enable: false }}
        {...(Platform.OS === 'android'
          ? { surfaceType: 'textureView' as const }
          : {})}
      />
      <Pressable style={StyleSheet.absoluteFill} onPress={togglePlayPause}>
        {userPaused && isActive ? (
          <View style={styles.pauseOverlay}>
            <View style={styles.pauseBadge}>
              <FontAwesome name="play" size={28} color="#fff" style={{ marginLeft: 4 }} />
            </View>
          </View>
        ) : null}
      </Pressable>
      {/* Above VideoView + pressable so dragged text sits on the video surface */}
      <MediaEditsOverlay edits={overlay} />
    </View>
  );
}

const styles = StyleSheet.create({
  black: {
    flex: 1,
    backgroundColor: '#000',
  },
  pauseOverlay: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  pauseBadge: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(0,0,0,0.45)',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
