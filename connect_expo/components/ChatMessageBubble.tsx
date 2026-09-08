/**
 * Flutter-style chat bubbles (ChatListItemNew / VoiceMessageBubble).
 * Own messages = pink; other = light grey. Parent handles left/right align + relative time.
 */
import { Brand } from '@/constants/Colors';
import { staticMapPreviewUrl } from '@/constants/maps';
import type { ChatMessage } from '@/services/chat';
import { generateVideoThumbnail } from '@/services/mediaThumbnail';
import { openChatMedia, useMediaOverlayStore } from '@/store/mediaViewerStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import {
  setAudioModeAsync,
  useAudioPlayer,
  useAudioPlayerStatus,
} from 'expo-audio';
import * as Linking from 'expo-linking';
import * as WebBrowser from 'expo-web-browser';
import { router } from 'expo-router';
import React, { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Image,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';

type Props = {
  message: ChatMessage;
  mine: boolean;
};

function formatDuration(seconds?: number) {
  const s = Math.max(0, Math.floor(seconds ?? 0));
  const m = Math.floor(s / 60);
  const r = s % 60;
  return `${m}:${r.toString().padStart(2, '0')}`;
}

const WAVE_HEIGHTS = [10, 16, 22, 14, 20, 12, 24, 15, 18, 11, 21, 13, 19, 17, 23];

export function ChatMessageBubble({ message, mine }: Props) {
  const type = String(message.messageType ?? 'text');

  if (type === 'image' && (message.files?.length ?? 0) > 0) {
    const files = message.files!;
    return (
      <View style={styles.imageWrap}>
        <View style={styles.imageGrid}>
          {files.slice(0, 4).map((uri) => (
            <Pressable
              key={uri}
              onPress={() => {
                openChatMedia(uri, { isImage: true });
                router.push('/chat/video');
              }}
            >
              <Image source={{ uri }} style={styles.gridImage} resizeMode="cover" />
            </Pressable>
          ))}
        </View>
      </View>
    );
  }

  if (type === 'video' && message.voiceData?.url) {
    return (
      <VideoBubble
        url={message.voiceData.url}
        duration={message.voiceData.duration}
      />
    );
  }

  if (type === 'document' && message.voiceData) {
    const meta = message.voiceData;
    return (
      <Pressable
        style={[styles.mediaBubble, mine ? styles.sentMedia : styles.recvMedia]}
        onPress={() => {
          const url = meta.url;
          if (!url) {
            Alert.alert('', 'Document link is missing.');
            return;
          }
          void (async () => {
            try {
              await WebBrowser.openBrowserAsync(url);
            } catch {
              try {
                await Linking.openURL(url);
              } catch {
                Alert.alert('', 'Could not open this document.');
              }
            }
          })();
        }}
      >
        <MaterialIcons
          name="insert-drive-file"
          size={28}
          color={mine ? Brand.white : Brand.black}
        />
        <View style={styles.docText}>
          <Text
            style={[styles.docName, { color: mine ? Brand.white : Brand.black }]}
            numberOfLines={2}
          >
            {meta.fileName || message.message || 'Document'}
          </Text>
          <Text
            style={[styles.docMeta, { color: mine ? Brand.white : Brand.black, opacity: 0.8 }]}
          >
            {(meta.fileExtension || 'FILE').toUpperCase()}
            {meta.fileSize ? ` · ${Math.round(meta.fileSize / 1024)} KB` : ''}
          </Text>
        </View>
      </Pressable>
    );
  }

  if (type === 'location' && message.voiceData) {
    const { latitude, longitude, address } = message.voiceData;
    const hasCoords = latitude != null && longitude != null;
    const mapUri = hasCoords
      ? staticMapPreviewUrl(Number(latitude), Number(longitude))
      : null;
    return (
      <Pressable
        style={[styles.locCard, mine ? styles.sentMedia : styles.recvMedia]}
        onPress={() => {
          if (!hasCoords) return;
          void Linking.openURL(
            `https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}`,
          );
        }}
      >
        {mapUri ? (
          <Image source={{ uri: mapUri }} style={styles.locMap} resizeMode="cover" />
        ) : null}
        <View style={styles.locRow}>
          <MaterialIcons
            name="location-on"
            size={22}
            color={mine ? Brand.white : Brand.primary}
          />
          <Text
            style={[styles.locText, { color: mine ? Brand.white : Brand.black }]}
            numberOfLines={3}
          >
            {address ||
              `Location (${Number(latitude).toFixed(4)}, ${Number(longitude).toFixed(4)})`}
          </Text>
        </View>
      </Pressable>
    );
  }

  if (type === 'voice' && message.voiceData?.url) {
    return (
      <View style={[styles.mediaBubble, mine ? styles.sentMedia : styles.recvMedia]}>
        <VoiceBubble
          url={message.voiceData.url}
          duration={message.voiceData.duration}
          mine={mine}
        />
      </View>
    );
  }

  // Flutter text: ClipRRect 15, pad V8 H12, font 16
  return (
    <View style={[styles.textBubble, mine ? styles.sentText : styles.recvText]}>
      <Text style={[styles.textMsg, { color: mine ? Brand.white : Brand.black }]}>
        {String(message.message ?? '')}
      </Text>
    </View>
  );
}

function VideoBubble({ url, duration }: { url: string; duration?: number }) {
  const [thumb, setThumb] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    generateVideoThumbnail(url, 800)
      .then((uri) => {
        if (!cancelled) setThumb(uri);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [url]);

  return (
    <Pressable
      style={styles.videoCard}
      onPress={() => {
        openChatMedia(url, {
          edits: useMediaOverlayStore.getState().get(url),
        });
        router.push('/chat/video');
      }}
    >
      {thumb ? (
        <Image source={{ uri: thumb }} style={styles.videoThumb} resizeMode="cover" />
      ) : (
        <View style={[styles.videoThumb, styles.videoPlaceholder]}>
          {loading ? (
            <ActivityIndicator color={Brand.white} />
          ) : (
            <MaterialIcons name="play-arrow" size={36} color={Brand.white} />
          )}
        </View>
      )}
      <View style={styles.videoPlay}>
        <MaterialIcons name="play-arrow" size={28} color={Brand.white} />
      </View>
      {duration != null && duration > 0 ? (
        <View style={styles.videoDur}>
          <Text style={styles.videoDurText}>{formatDuration(duration)}</Text>
        </View>
      ) : null}
    </Pressable>
  );
}

function VoiceBubble({
  url,
  duration,
  mine,
}: {
  url: string;
  duration?: number;
  mine: boolean;
}) {
  const player = useAudioPlayer(url, { downloadFirst: true, updateInterval: 100 });
  const status = useAudioPlayerStatus(player);
  const [busyPlay, setBusyPlay] = useState(false);
  const totalSec =
    status.duration > 0 ? status.duration : Math.max(0, Number(duration) || 0);
  const currentSec = status.currentTime ?? 0;
  const progress =
    totalSec > 0 ? Math.min(1, Math.max(0, currentSec / totalSec)) : 0;
  const playing = !!status.playing;
  const bars = useMemo(() => WAVE_HEIGHTS, []);
  const accent = mine ? Brand.white : Brand.primary;
  const muted = mine ? 'rgba(255,255,255,0.35)' : 'rgba(0,0,0,0.2)';

  async function toggle() {
    if (busyPlay) return;
    setBusyPlay(true);
    try {
      await setAudioModeAsync({
        allowsRecording: false,
        playsInSilentMode: true,
        interruptionMode: 'mixWithOthers',
      });
      if (playing) {
        player.pause();
        return;
      }
      if (totalSec > 0 && currentSec >= totalSec - 0.25) await player.seekTo(0);
      player.play();
    } catch {
      Alert.alert('', 'Unable to play voice message.');
    } finally {
      setBusyPlay(false);
    }
  }

  return (
    <View style={styles.voiceRow}>
      <Pressable style={styles.voiceBtn} onPress={() => void toggle()}>
        {busyPlay || (status.isBuffering && !playing) ? (
          <ActivityIndicator color={accent} size="small" />
        ) : (
          <MaterialIcons
            name={playing ? 'pause' : 'play-arrow'}
            size={24}
            color={accent}
          />
        )}
      </Pressable>
      <View style={styles.waveWrap}>
        <View style={styles.waveRow}>
          {bars.map((h, i) => (
            <View
              key={i}
              style={[
                styles.waveBar,
                {
                  height: h,
                  backgroundColor: i / bars.length <= progress ? accent : muted,
                },
              ]}
            />
          ))}
        </View>
        <Text style={[styles.voiceTime, { color: mine ? '#FFE8EC' : '#666' }]}>
          {formatDuration(playing || currentSec > 0.05 ? currentSec : totalSec)}
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  textBubble: {
    maxWidth: 280,
    borderRadius: 15,
    paddingVertical: 8,
    paddingHorizontal: 12,
  },
  sentText: { backgroundColor: Brand.primaryBottom },
  recvText: { backgroundColor: 'rgba(48,48,48,0.2)' },
  textMsg: { fontSize: 16, fontWeight: '400', lineHeight: 22 },

  mediaBubble: {
    maxWidth: 280,
    minWidth: 180,
    borderRadius: 20,
    paddingVertical: 12,
    paddingHorizontal: 14,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  sentMedia: { backgroundColor: 'rgba(239,39,77,0.9)' },
  recvMedia: {
    backgroundColor: Brand.white,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: '#E0E0E0',
  },

  imageWrap: { maxWidth: 250 },
  imageGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 5 },
  gridImage: { width: 120, height: 120, borderRadius: 12 },

  videoCard: {
    width: 90,
    height: 100,
    borderRadius: 10,
    overflow: 'hidden',
    backgroundColor: '#000',
  },
  videoThumb: { width: '100%', height: '100%' },
  videoPlaceholder: { alignItems: 'center', justifyContent: 'center' },
  videoPlay: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0,0,0,0.25)',
  },
  videoDur: {
    position: 'absolute',
    right: 4,
    bottom: 4,
    backgroundColor: 'rgba(0,0,0,0.55)',
    paddingHorizontal: 4,
    borderRadius: 3,
  },
  videoDurText: { color: Brand.white, fontSize: 10, fontWeight: '600' },

  docText: { flex: 1 },
  docName: { fontSize: 14, fontWeight: '600' },
  docMeta: { fontSize: 11, marginTop: 2 },

  locCard: { maxWidth: 220, overflow: 'hidden', padding: 0 },
  locMap: { width: 220, height: 100 },
  locRow: {
    flexDirection: 'row',
    gap: 8,
    padding: 10,
    alignItems: 'flex-start',
  },
  locText: { flex: 1, fontSize: 13, lineHeight: 18 },

  voiceRow: { flexDirection: 'row', alignItems: 'center', gap: 10, flex: 1 },
  voiceBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.2)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  waveWrap: { flex: 1 },
  waveRow: {
    height: 28,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  waveBar: { width: 2.5, borderRadius: 2 },
  voiceTime: { fontSize: 11, marginTop: 4 },
});
