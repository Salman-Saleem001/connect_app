/**
 * Post-capture editor for Expo Go — text, music, and color filters
 * (same tools as Flutter VideoEditScreen). Uses only Expo SDK modules
 * (`expo-video`, `expo-audio`); no custom native modules required.
 */
import { PrimaryButton } from '@/components/PrimaryButton';
import {
  DraggableTextOverlay,
  type TextOverlayStyle,
} from '@/components/DraggableTextOverlay';
import { Brand } from '@/constants/Colors';
import {
  buildChatRoomId,
  createChatRoom,
  uploadChatMedia,
} from '@/services/chat';
import { createStory, getStories } from '@/services/api/posts';
import { useAuthStore } from '@/store/authStore';
import type { MediaEdits } from '@/store/mediaViewerStore';
import {
  sanitizeMediaEdits,
  useMediaOverlayStore,
} from '@/store/mediaViewerStore';
import { notify } from '@/store/notificationStore';
import { usePostDraftStore } from '@/store/postDraftStore';
import { useStoriesStore } from '@/store/storiesStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { setAudioModeAsync, useAudioPlayer } from 'expo-audio';
import { useVideoPlayer, VideoView } from 'expo-video';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Image,
  Keyboard,
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  type LayoutChangeEvent,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { captureRef } from 'react-native-view-shot';

const FILTER_COLORS = [
  '#F44336',
  '#E91E63',
  '#9C27B0',
  '#673AB7',
  '#3F51B5',
  '#2196F3',
  '#03A9F4',
  '#00BCD4',
  '#009688',
  '#4CAF50',
  '#8BC34A',
  '#CDDC39',
  '#FFEB3B',
  '#FFC107',
  '#FF9800',
  '#FF5722',
  '#795548',
  '#9E9E9E',
  '#607D8B',
  '#000000',
] as const;

const AUDIO_TRACKS = [
  { id: 'distant', label: 'Distant', source: require('../../assets/audio/distant.mp3') },
  { id: 'stock', label: 'Stock', source: require('../../assets/audio/stock.mp3') },
  { id: 'sunlit', label: 'Sunlit', source: require('../../assets/audio/sunlit.mp3') },
] as const;

const TEXT_COLORS = [
  Brand.white,
  '#FFEB3B',
  Brand.primary,
  '#4CAF50',
  '#2196F3',
  '#000000',
] as const;

export default function ChatMediaPreviewScreen() {
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams<{
    uri?: string;
    isVideo?: string;
    secondUserId?: string;
    userName?: string;
    description?: string;
    userAvatar?: string;
    bio?: string;
    videoId?: string;
    tags?: string;
    fromStory?: string;
    fromPost?: string;
  }>();

  const me = useAuthStore((s) => s.user);
  const token = useAuthStore((s) => s.token);
  const myId = me?.id != null ? String(me.id) : '';
  const uri = typeof params.uri === 'string' ? params.uri : '';
  const isVideo = params.isVideo !== '0';
  const fromStory = params.fromStory === '1';
  const fromPost = params.fromPost === '1';
  const videoId = Number(params.videoId ?? 0);
  const secondUserId = params.secondUserId ?? '';

  const [sending, setSending] = useState(false);
  const [playing, setPlaying] = useState(true);

  const [showTextField, setShowTextField] = useState(false);
  const [previewSize, setPreviewSize] = useState({ width: 0, height: 0 });
  const [textOverlay, setTextOverlay] = useState<TextOverlayStyle>({
    text: '',
    color: Brand.white,
    fontSize: 28,
    bold: true,
    x: 40,
    y: 200,
  });
  const [showFilters, setShowFilters] = useState(false);
  const [filterColor, setFilterColor] = useState<string | null>(null);
  const [musicOpen, setMusicOpen] = useState(false);
  const [selectedAudio, setSelectedAudio] = useState<string | null>(null);
  const [previewingAudioId, setPreviewingAudioId] = useState<string | null>(null);
  const audioPlayer = useAudioPlayer(null);
  const captureTargetRef = useRef<View>(null);

  function patchText(next: Partial<TextOverlayStyle>) {
    setTextOverlay((prev) => ({ ...prev, ...next }));
  }

  function buildMessageEdits(): MediaEdits | null {
    const hasText = !!textOverlay.text.trim();
    const hasFilter = !!filterColor;
    const hasMusic = !!selectedAudio;
    if (!hasText && !hasFilter && !hasMusic) return null;
    const w = Math.max(previewSize.width, 1);
    const h = Math.max(previewSize.height, 1);
    return sanitizeMediaEdits({
      text: hasText ? textOverlay.text.trim() : undefined,
      textColor: textOverlay.color,
      fontSize: textOverlay.fontSize,
      bold: textOverlay.bold,
      xNorm: textOverlay.x / w,
      yNorm: textOverlay.y / h,
      filterColor: filterColor,
      audioId: selectedAudio,
    });
  }

  function openTextTool() {
    setShowFilters(false);
    setMusicOpen(false);
    setShowTextField(true);
    if (previewSize.width > 0 && !textOverlay.text.trim()) {
      patchText({
        x: Math.max(24, previewSize.width / 2 - 80),
        y: Math.max(80, previewSize.height / 2 - 40),
      });
    }
  }

  function onPreviewLayout(e: LayoutChangeEvent) {
    const { width, height } = e.nativeEvent.layout;
    setPreviewSize({ width, height });
  }

  const player = useVideoPlayer(isVideo && uri ? uri : null, (p) => {
    p.loop = true;
    p.play();
  });

  useEffect(() => {
    void (async () => {
      try {
        await setAudioModeAsync({
          playsInSilentMode: true,
          interruptionMode: 'mixWithOthers',
          shouldPlayInBackground: false,
        });
      } catch {
        // iOS may reject if another app owns the session (!pri / 561017449)
      }
    })();
  }, []);

  useEffect(() => {
    return () => {
      try {
        player.pause();
      } catch {
        // ignore
      }
      try {
        audioPlayer.pause();
      } catch {
        // ignore
      }
    };
  }, [player, audioPlayer]);

  function unloadSound() {
    try {
      audioPlayer.pause();
    } catch {
      // ignore
    }
    setPreviewingAudioId(null);
  }

  async function previewTrack(id: string, source: number) {
    try {
      // Avoid AVAudioSession conflicts with the video player
      if (isVideo) {
        try {
          player.pause();
          setPlaying(false);
        } catch {
          // ignore
        }
      }

      try {
        await setAudioModeAsync({
          playsInSilentMode: true,
          interruptionMode: 'mixWithOthers',
          shouldPlayInBackground: false,
        });
      } catch {
        // Continue — mode may already be set
      }

      audioPlayer.replace(source);
      audioPlayer.loop = true;
      await audioPlayer.seekTo(0);
      audioPlayer.play();
      setPreviewingAudioId(id);
    } catch {
      setPreviewingAudioId(null);
      Alert.alert('', 'Unable to preview this track.');
    }
  }

  function togglePlay() {
    if (!isVideo) return;
    try {
      if (playing) {
        player.pause();
        setPlaying(false);
      } else {
        player.play();
        setPlaying(true);
      }
    } catch {
      // ignore
    }
  }

  function onBack() {
    try {
      player.pause();
    } catch {
      // ignore
    }
    unloadSound();
    if (router.canGoBack()) router.back();
    else if (router.canDismiss()) router.dismiss();
  }

  async function onSend() {
    if (!uri) {
      Alert.alert('Error', 'Missing media.');
      return;
    }

    if (fromStory) {
      if (!token) {
        Alert.alert('Error', 'Please login again.');
        return;
      }
      setSending(true);
      setShowTextField(false);
      Keyboard.dismiss();
      try {
        try {
          player.pause();
        } catch {
          // ignore
        }
        unloadSound();
        await new Promise((r) => setTimeout(r, 50));

        let uploadUri = uri;
        const messageEdits = buildMessageEdits();
        if (!isVideo && messageEdits && captureTargetRef.current) {
          try {
            uploadUri = await captureRef(captureTargetRef, {
              format: 'jpg',
              quality: 0.92,
              result: 'tmpfile',
            });
          } catch {
            // keep original
          }
        }

        const lower = uploadUri.toLowerCase().split('?')[0];
        const extMatch = lower.match(/\.([a-z0-9]+)$/);
        const ext = extMatch?.[1] ?? (isVideo ? 'mp4' : 'jpg');

        let mimeType = 'image/jpeg';
        let fileName = `story_${Date.now()}.${ext}`;
        if (isVideo || ['mp4', 'mov', 'm4v', 'avi', 'webm'].includes(ext)) {
          mimeType =
            ext === 'mov' || ext === 'm4v'
              ? 'video/quicktime'
              : ext === 'webm'
                ? 'video/webm'
                : 'video/mp4';
          fileName = `story_${Date.now()}.${ext === 'mov' ? 'mov' : 'mp4'}`;
        } else if (ext === 'png') {
          mimeType = 'image/png';
        } else if (ext === 'gif') {
          mimeType = 'image/gif';
        } else if (ext === 'webp') {
          mimeType = 'image/webp';
        }

        const caption = textOverlay.text.trim();
        const {
          beginUpload,
          setUploadProgress,
          finishUpload,
          setPayload,
        } = useStoriesStore.getState();

        // Instagram-style: leave preview immediately and show progress on My Story ring
        beginUpload(isVideo ? null : uploadUri);
        setSending(false);
        if (router.canDismiss()) router.dismissAll();
        router.replace('/(tabs)/chats');

        void (async () => {
          try {
            await createStory(
              token,
              caption,
              uploadUri,
              mimeType,
              fileName,
              (p) => setUploadProgress(p),
            );
            setUploadProgress(1);
            const data = await getStories(token);
            setPayload(data);
            notify('Your story is live', {
              title: 'Story posted',
              kind: 'success',
              route: { type: 'chats' },
              inbox: true,
            });
          } catch (e) {
            Alert.alert(
              'Backend error',
              e instanceof Error ? e.message : 'Failed to post story.',
            );
          } finally {
            finishUpload();
          }
        })();
      } catch (e) {
        Alert.alert(
          'Backend error',
          e instanceof Error ? e.message : 'Failed to post story.',
        );
        setSending(false);
      }
      return;
    }

    // Home feed create-post flow (Flutter Camera → Edit → CreatePostScreen)
    if (fromPost) {
      setSending(true);
      setShowTextField(false);
      Keyboard.dismiss();
      try {
        try {
          player.pause();
        } catch {
          // ignore
        }
        unloadSound();
        await new Promise((r) => setTimeout(r, 50));

        let uploadUri = uri;
        const messageEdits = buildMessageEdits();
        if (!isVideo && messageEdits && captureTargetRef.current) {
          try {
            uploadUri = await captureRef(captureTargetRef, {
              format: 'jpg',
              quality: 0.92,
              result: 'tmpfile',
            });
          } catch {
            // keep original
          }
        }

        // Videos can't bake text in Expo Go — carry overlays into create-post / feed.
        usePostDraftStore
          .getState()
          .setMediaEdits(isVideo ? messageEdits : null);
        if (isVideo && messageEdits) {
          useMediaOverlayStore.getState().remember(uploadUri, messageEdits);
        }

        router.replace({
          pathname: '/chat/create-post',
          params: {
            uri: uploadUri,
            isVideo: isVideo ? '1' : '0',
          },
        });
      } catch (e) {
        Alert.alert(
          'Error',
          e instanceof Error ? e.message : 'Could not continue to post.',
        );
      } finally {
        setSending(false);
      }
      return;
    }

    if (!myId || !secondUserId || !videoId) {
      Alert.alert('Error', 'Missing media or user info.');
      return;
    }

    setSending(true);
    setShowTextField(false);
    Keyboard.dismiss();
    try {
      try {
        player.pause();
      } catch {
        // ignore
      }
      unloadSound();

      // Give the UI a tick so Done chrome is hidden before image capture
      await new Promise((r) => setTimeout(r, 50));

      let uploadUri = uri;
      let bakedImage = false;
      const messageEdits = buildMessageEdits();

      // Images: bake filter + text into a still via view-shot (Expo Go friendly)
      if (!isVideo && messageEdits && captureTargetRef.current) {
        try {
          uploadUri = await captureRef(captureTargetRef, {
            format: 'jpg',
            quality: 0.92,
            result: 'tmpfile',
          });
          bakedImage = true;
        } catch {
          // Fall back to original + overlay metadata
        }
      }

      const mediaUrl = await uploadChatMedia(
        uploadUri,
        myId,
        isVideo ? 'video' : 'image',
      );
      const chatRoomId = buildChatRoomId(Number(myId), Number(secondUserId), videoId);
      const editsToSave = isVideo || !bakedImage ? messageEdits : null;
      await createChatRoom({
        myUserId: myId,
        myUsername: me?.username ?? me?.first_name ?? '',
        myAvatar: me?.avatar ?? '',
        secondUserId,
        chatRoomId,
        userName: params.userName ?? '',
        description: params.description ?? '',
        tags: params.tags ?? '',
        videoUrl: mediaUrl,
        userAvatar: params.userAvatar ?? '',
        videoId,
        // Videos: can't re-encode in Expo Go — keep overlays for playback.
        // Images: only keep edits if bake failed (otherwise they'd double-draw).
        messageEdits: editsToSave,
      });
      if (isVideo && editsToSave) {
        useMediaOverlayStore.getState().remember(mediaUrl, editsToSave);
      }
      notify('Connection request sent — waiting for them to accept', {
        title: 'Video reply sent',
        kind: 'success',
        route: {
          type: 'chat',
          videoId,
          secondUserId,
          userName: params.userName ?? '',
          userAvatar: params.userAvatar ?? '',
          description: params.description ?? '',
          tags: params.tags ?? '',
          bio: params.bio ?? '',
          otherStatus: 'Pending',
          myStatus: 'Accepted',
        },
        inbox: true,
      });
      // Back to chat detail (camera used replace → preview, so replace chat again)
      router.replace({
        pathname: '/chat/[videoId]',
        params: {
          videoId: String(videoId),
          secondUserId,
          userName: params.userName ?? '',
          description: params.description ?? '',
          userAvatar: params.userAvatar ?? '',
          bio: params.bio ?? '',
          tags: params.tags ?? '',
        },
      });
    } catch (e) {
      Alert.alert(
        'Backend error',
        e instanceof Error
          ? e.message
          : `Failed to send ${isVideo ? 'video' : 'image'}.`,
      );
    } finally {
      setSending(false);
    }
  }

  const title = fromStory
    ? 'New Story'
    : fromPost
      ? isVideo
        ? 'Edit Video'
        : 'Edit Image'
      : isVideo
        ? 'Edit Video'
        : 'Edit Image';
  const buttonLabel = fromStory
    ? 'Share Story'
    : fromPost
      ? 'Save Changes'
      : isVideo
        ? 'Send Video'
        : 'Send Image';
  const hasEdits = !!(textOverlay.text.trim() || filterColor || selectedAudio);

  return (
    <View style={styles.root}>
      <View style={styles.previewArea} onLayout={onPreviewLayout} ref={captureTargetRef} collapsable={false}>
        {uri && isVideo ? (
          <Pressable style={styles.mediaFill} onPress={togglePlay}>
            <VideoView
              style={StyleSheet.absoluteFill}
              player={player}
              contentFit="contain"
              nativeControls={false}
            />
            {!playing && !sending ? (
              <View style={styles.playOverlay} pointerEvents="none">
                <View style={styles.playBadge}>
                  <MaterialIcons name="play-arrow" size={40} color={Brand.white} />
                </View>
              </View>
            ) : null}
          </Pressable>
        ) : uri ? (
          <Image source={{ uri }} style={styles.image} resizeMode="contain" />
        ) : (
          <View style={styles.center}>
            <Text style={styles.emptyText}>No preview available</Text>
          </View>
        )}

        {filterColor ? (
          <View
            pointerEvents="none"
            style={[styles.filterOverlay, { backgroundColor: filterColor }]}
          />
        ) : null}

        {(showTextField || textOverlay.text.trim()) && previewSize.width > 0 ? (
          <DraggableTextOverlay
            value={textOverlay}
            editing={showTextField && !sending}
            bounds={previewSize}
            onChange={patchText}
            onRequestEdit={() => {
              if (sending) return;
              setShowFilters(false);
              setMusicOpen(false);
              setShowTextField(true);
            }}
            onDone={() => {
              Keyboard.dismiss();
              setShowTextField(false);
            }}
          />
        ) : null}

        {showTextField && !sending ? (
          <View style={[styles.colorBar, { bottom: 12 }]}>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.textColorRow}
            >
              {TEXT_COLORS.map((c) => (
                <Pressable
                  key={c}
                  onPress={() => patchText({ color: c })}
                  style={[
                    styles.textColorDot,
                    { backgroundColor: c },
                    textOverlay.color === c && styles.textColorDotActive,
                  ]}
                />
              ))}
            </ScrollView>
          </View>
        ) : null}
      </View>

      <View style={[styles.topBar, { top: insets.top + 25 }]} pointerEvents="box-none">
        <Pressable style={styles.circleBtn} hitSlop={12} onPress={onBack}>
          <MaterialIcons
            name="arrow-back-ios-new"
            size={15}
            color={Brand.primaryIconColor}
          />
        </Pressable>
        <Text style={styles.title} numberOfLines={1}>
          {title}
        </Text>
        <View style={styles.topBarSpacer} />
      </View>

      <View style={styles.editRail} pointerEvents="box-none">
        <View style={styles.editRailInner}>
          <Pressable
            style={styles.editIconBtn}
            onPress={() => {
              if (showTextField) setShowTextField(false);
              else openTextTool();
            }}
          >
            <Image
              source={require('../../assets/images/text_icon.png')}
              style={[
                styles.editIconImg,
                (showTextField || !!textOverlay.text.trim()) &&
                  styles.editIconImgActive,
              ]}
              resizeMode="contain"
            />
          </Pressable>
          <Pressable
            style={styles.editIconBtn}
            onPress={() => {
              setShowFilters(false);
              setShowTextField(false);
              if (isVideo) {
                try {
                  player.pause();
                  setPlaying(false);
                } catch {
                  // ignore
                }
              }
              setMusicOpen(true);
            }}
          >
            <Image
              source={require('../../assets/images/music_icon.png')}
              style={[
                styles.editIconImg,
                !!selectedAudio && styles.editIconImgActive,
              ]}
              resizeMode="contain"
            />
          </Pressable>
          <Pressable
            style={styles.editIconBtn}
            onPress={() => {
              setShowTextField(false);
              setMusicOpen(false);
              setShowFilters((v) => !v);
            }}
          >
            <Image
              source={require('../../assets/images/filters_icon.png')}
              style={[
                styles.editIconImg,
                (showFilters || !!filterColor) && styles.editIconImgActive,
              ]}
              resizeMode="contain"
            />
          </Pressable>
        </View>
        {hasEdits ? (
          <Pressable
            style={styles.clearEdits}
            onPress={() => {
              setTextOverlay({
                text: '',
                color: Brand.white,
                fontSize: 28,
                bold: true,
                x: Math.max(24, previewSize.width / 2 - 80),
                y: Math.max(80, previewSize.height / 2 - 40),
              });
              setFilterColor(null);
              setSelectedAudio(null);
              setShowTextField(false);
              setShowFilters(false);
              unloadSound();
            }}
          >
            <MaterialIcons name="refresh" size={18} color={Brand.white} />
          </Pressable>
        ) : null}
      </View>

      {showFilters ? (
        <View style={[styles.filterStrip, { bottom: 100 + insets.bottom }]}>
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.filterScroll}
          >
            <Pressable
              onPress={() => setFilterColor(null)}
              style={[
                styles.filterSwatch,
                !filterColor && styles.filterSwatchActive,
                { backgroundColor: '#333' },
              ]}
            >
              <MaterialIcons name="block" size={22} color={Brand.white} />
            </Pressable>
            {FILTER_COLORS.map((c) => (
              <Pressable
                key={c}
                onPress={() => setFilterColor(c)}
                style={[
                  styles.filterSwatch,
                  { backgroundColor: c },
                  filterColor === c && styles.filterSwatchActive,
                ]}
              >
                <Image
                  source={require('../../assets/images/filter_picture.png')}
                  style={styles.filterThumb}
                  resizeMode="cover"
                />
              </Pressable>
            ))}
          </ScrollView>
        </View>
      ) : null}

      {selectedAudio && !musicOpen ? (
        <View style={[styles.musicChip, { bottom: 100 + insets.bottom }]}>
          <MaterialIcons name="music-note" size={16} color={Brand.white} />
          <Text style={styles.musicChipText}>
            {AUDIO_TRACKS.find((t) => t.id === selectedAudio)?.label ?? selectedAudio}
          </Text>
        </View>
      ) : null}

      <View style={[styles.bottomBar, { paddingBottom: Math.max(insets.bottom, 16) }]}>
        {sending ? (
          <ActivityIndicator color={Brand.primary} style={{ alignSelf: 'center' }} />
        ) : (
          <PrimaryButton label={buttonLabel} onPress={onSend} />
        )}
      </View>

      <Modal
        visible={musicOpen}
        animationType="slide"
        transparent
        onRequestClose={() => {
          setMusicOpen(false);
          unloadSound();
        }}
      >
        <Pressable
          style={styles.sheetBackdrop}
          onPress={() => {
            setMusicOpen(false);
            unloadSound();
          }}
        />
        <View style={[styles.sheet, { paddingBottom: Math.max(insets.bottom, 20) }]}>
          <View style={styles.sheetHandle} />
          <Text style={styles.sheetTitle}>Choose Music</Text>
          {AUDIO_TRACKS.map((track) => {
            const selected = selectedAudio === track.id;
            const previewing = previewingAudioId === track.id;
            return (
              <Pressable
                key={track.id}
                style={[styles.trackRow, selected && styles.trackRowSelected]}
                onPress={() => setSelectedAudio(track.id)}
              >
                <Text style={[styles.trackLabel, selected && styles.trackLabelSelected]}>
                  {track.label}
                </Text>
                <Pressable
                  hitSlop={8}
                  onPress={() => {
                    if (previewing) unloadSound();
                    else void previewTrack(track.id, track.source);
                  }}
                >
                  <MaterialIcons
                    name={previewing ? 'pause' : 'play-arrow'}
                    size={28}
                    color={selected ? Brand.black : Brand.white}
                  />
                </Pressable>
              </Pressable>
            );
          })}
          <Pressable
            style={styles.sheetConfirm}
            onPress={() => {
              setMusicOpen(false);
              unloadSound();
            }}
          >
            <MaterialIcons name="check" size={22} color={Brand.black} />
          </Pressable>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#000' },
  previewArea: {
    flex: 1,
    backgroundColor: '#000',
    marginBottom: 90,
  },
  mediaFill: { flex: 1, backgroundColor: '#000' },
  image: { flex: 1, width: '100%', backgroundColor: '#000' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  emptyText: { color: Brand.white, fontSize: 14 },
  filterOverlay: {
    ...StyleSheet.absoluteFill,
    opacity: 0.4,
  },
  playOverlay: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
  },
  playBadge: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(0,0,0,0.45)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  colorBar: {
    position: 'absolute',
    left: 0,
    right: 56,
    zIndex: 30,
    paddingLeft: 12,
  },
  textColorRow: {
    gap: 12,
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 8,
  },
  textColorDot: {
    width: 28,
    height: 28,
    borderRadius: 14,
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.35)',
  },
  textColorDotActive: {
    borderColor: Brand.white,
    borderWidth: 3,
  },
  topBar: {
    position: 'absolute',
    left: 0,
    right: 0,
    height: 56,
    zIndex: 20,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  topBarSpacer: { width: 44, height: 44, margin: 8 },
  circleBtn: {
    margin: 8,
    width: 44,
    height: 44,
    borderRadius: 22,
    borderWidth: 1.5,
    borderColor: '#000',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Brand.white,
  },
  title: {
    flex: 1,
    textAlign: 'center',
    color: Brand.white,
    fontSize: 18,
    fontWeight: '700',
    fontFamily: 'SF-Pro-Display',
  },
  editRail: {
    position: 'absolute',
    right: 40,
    top: '33%',
    zIndex: 40,
    elevation: 40,
    alignItems: 'center',
    gap: 10,
  },
  editRailInner: {
    backgroundColor: Brand.white,
    borderRadius: 15,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#000',
  },
  editIconBtn: {
    paddingHorizontal: 10,
    paddingVertical: 15,
    alignItems: 'center',
    justifyContent: 'center',
  },
  editIconImg: {
    width: 28,
    height: 28,
    tintColor: '#9E9E9E',
  },
  editIconImgActive: {
    tintColor: Brand.primary,
  },
  clearEdits: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(0,0,0,0.55)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  filterStrip: {
    position: 'absolute',
    left: 0,
    right: 0,
    zIndex: 35,
    elevation: 35,
  },
  filterScroll: {
    paddingHorizontal: 16,
    gap: 10,
    alignItems: 'center',
  },
  filterSwatch: {
    width: 72,
    height: 56,
    borderRadius: 10,
    overflow: 'hidden',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: 'transparent',
  },
  filterSwatchActive: {
    borderColor: Brand.white,
  },
  filterThumb: {
    ...StyleSheet.absoluteFill,
    opacity: 0.45,
  },
  musicChip: {
    position: 'absolute',
    left: 16,
    zIndex: 35,
    elevation: 35,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(0,0,0,0.55)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
  },
  musicChipText: { color: Brand.white, fontSize: 13, fontWeight: '600' },
  bottomBar: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: Brand.white,
    paddingHorizontal: 30,
    paddingTop: 20,
    zIndex: 30,
    elevation: 30,
  },
  sheetBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.45)',
  },
  sheet: {
    backgroundColor: 'rgba(20,20,20,0.96)',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingHorizontal: 24,
    paddingTop: 10,
    maxHeight: '50%',
  },
  sheetHandle: {
    alignSelf: 'center',
    width: 40,
    height: 4,
    borderRadius: 2,
    backgroundColor: '#666',
    marginBottom: 14,
  },
  sheetTitle: {
    color: Brand.white,
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 12,
  },
  trackRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
    paddingHorizontal: 12,
    borderRadius: 10,
    marginBottom: 8,
  },
  trackRowSelected: { backgroundColor: Brand.white },
  trackLabel: { color: Brand.white, fontSize: 22, fontWeight: '500' },
  trackLabelSelected: { color: Brand.black },
  sheetConfirm: {
    position: 'absolute',
    right: 24,
    bottom: 28,
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: Brand.white,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
