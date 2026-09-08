import { Brand } from '@/constants/Colors';
import { ChatAttachmentSheet } from '@/components/ChatAttachmentSheet';
import { ChatMessageBubble } from '@/components/ChatMessageBubble';
import {
  getSingleChatDetail,
  listenMessages,
  listenSingleChatDetail,
  sendTextMessage,
  updateAcceptanceStatus,
  type ChatDataModel,
  type ChatMessage,
} from '@/services/chat';
import {
  pickAndSendGalleryVideo,
  pickAndSendPhotos,
  sendRecordedVoice,
} from '@/services/chatAttachments';
import {
  pickOfficeDocument,
  sendOfficeDocument,
} from '@/services/documentAttach';
import { generateVideoThumbnail } from '@/services/mediaThumbnail';
import { useAuthStore } from '@/store/authStore';
import { openChatMedia, useMediaOverlayStore } from '@/store/mediaViewerStore';
import {
  notify,
  roomNotificationKey,
  useNotificationStore,
} from '@/store/notificationStore';
import { formatRelativeChatTime } from '@/utils/chatTime';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import {
  RecordingPresets,
  requestRecordingPermissionsAsync,
  setAudioModeAsync,
  useAudioRecorder,
  useAudioRecorderState,
} from 'expo-audio';
import { router, useFocusEffect, useLocalSearchParams } from 'expo-router';
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Image,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

/** Expo Router may return string | string[] for the same key. */
function readParam(value?: string | string[]) {
  if (Array.isArray(value)) return value[0] ?? '';
  return value ?? '';
}

/** Mirrors Flutter `UserAvatarImage` (CircleAvatar). */
function UserAvatar({ uri, radius = 20 }: { uri?: string; radius?: number }) {
  const size = radius * 2;
  const absolute = !!uri && /^https?:\/\//i.test(uri.trim());
  const source = {
    uri: absolute
      ? uri!.trim()
      : 'https://cdn-icons-png.flaticon.com/512/61/61205.png',
  };

  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: radius,
        overflow: 'hidden',
        backgroundColor: Brand.white,
      }}
    >
      <Image source={source} style={{ width: size, height: size }} resizeMode="cover" />
    </View>
  );
}

/** Mirrors Flutter `hashtagChip`. */
function HashtagChip({ label }: { label: string }) {
  const text = label.startsWith('#') ? label : `#${label}`;
  return (
    <View style={styles.chip}>
      <Text style={styles.chipText}>{text}</Text>
    </View>
  );
}

export default function ChatDetailScreen() {
  const raw = useLocalSearchParams();

  const me = useAuthStore((s) => s.user);
  const myId = me?.id != null ? String(me.id) : '';

  const videoId = Number(readParam(raw.videoId as string | string[]));
  const secondUserIdParam = readParam(raw.secondUserId as string | string[]);
  const userName = readParam(raw.userName as string | string[]);
  const description =
    readParam(raw.description as string | string[]) ||
    'Anyone heading to Phoenix Game Tonight?';
  const userAvatar = readParam(raw.userAvatar as string | string[]);
  const bio = readParam(raw.bio as string | string[]);
  const tagsParam = readParam(raw.tags as string | string[]);
  const chatsId = readParam(raw.chatsId as string | string[]);
  const senderId = readParam(raw.senderId as string | string[]);
  const receiverId = readParam(raw.receiverId as string | string[]);
  const myStatusParam = readParam(raw.myStatus as string | string[]);
  const otherStatusParam = readParam(raw.otherStatus as string | string[]);
  const messageData = readParam(raw.messageData as string | string[]);

  const tags = useMemo(() => {
    if (!tagsParam) return [];
    const list = tagsParam.includes(',')
      ? tagsParam.split(',').filter(Boolean)
      : tagsParam
          .split('#')
          .filter(Boolean)
          .map((t) => (t.startsWith('#') ? t : `#${t}`));
    const seen = new Set<string>();
    return list.filter((t) => {
      const key = t.replace(/^#/, '').trim().toLowerCase();
      if (!key || seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  }, [tagsParam]);

  const inferredSecondUserId = useMemo(() => {
    if (secondUserIdParam) return secondUserIdParam;
    if (senderId && senderId !== myId) return senderId;
    if (receiverId && receiverId !== myId) return receiverId;
    return '';
  }, [secondUserIdParam, senderId, receiverId, myId]);

  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [chat, setChat] = useState<ChatDataModel | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [text, setText] = useState('');
  /** Flutter `chatController.thumbnail` — auto-generated from message video */
  const [videoThumb, setVideoThumb] = useState<string | null>(null);
  const [thumbLoading, setThumbLoading] = useState(false);
  const [attachVisible, setAttachVisible] = useState(false);
  const [attachMode, setAttachMode] = useState<'attach' | 'gallery'>('attach');
  const [uploadingAttach, setUploadingAttach] = useState(false);
  const [recordingUi, setRecordingUi] = useState(false);
  const [sendingVoice, setSendingVoice] = useState(false);
  const recordStartedAt = useRef(0);
  /** True while finger is held on mic (handles async prepare race). */
  const micHeldRef = useRef(false);
  const recordingActiveRef = useRef(false);
  const finishingVoiceRef = useRef(false);

  const audioRecorder = useAudioRecorder(RecordingPresets.HIGH_QUALITY);
  const recorderState = useAudioRecorderState(audioRecorder);

  const refresh = useCallback(async () => {
    if (!myId) {
      setLoading(false);
      setError('Please login again.');
      return;
    }
    if (!inferredSecondUserId || !videoId) {
      // Existing room passed from Chats list
      if (chatsId) {
        setChat({
          chatsId: chatsId,
          senderId: senderId,
          receiverId: receiverId,
          myStatus: myStatusParam,
          otherStatus: otherStatusParam,
          messageData: messageData,
          videoId,
          userName,
          description,
          avatar: userAvatar,
          tags: tagsParam,
        });
        setLoading(false);
        return;
      }
      setLoading(false);
      setError('Missing user or video info.');
      return;
    }

    setLoading(true);
    setError(null);
    try {
      const data = await getSingleChatDetail(myId, inferredSecondUserId, videoId);
      setChat(data);
    } catch (e) {
      const msg = e instanceof Error ? e.message : 'Failed to load chat from backend';
      setError(msg);
      setChat(null);
    } finally {
      setLoading(false);
    }
  }, [
    myId,
    inferredSecondUserId,
    videoId,
    chatsId,
    senderId,
    receiverId,
    myStatusParam,
    otherStatusParam,
    messageData,
    tagsParam,
    userName,
    description,
    userAvatar,
  ]);

  useFocusEffect(
    useCallback(() => {
      refresh();
      return () => {
        useNotificationStore.getState().setActiveChatRoomId(null);
      };
    }, [refresh]),
  );

  // Live room status so Accept/Decline updates for both parties without leaving
  useEffect(() => {
    if (!myId || !inferredSecondUserId || !videoId) return;
    return listenSingleChatDetail(
      myId,
      inferredSecondUserId,
      videoId,
      (data) => {
        if (data) setChat(data);
      },
      (err) => setError(err.message),
    );
  }, [myId, inferredSecondUserId, videoId]);

  useEffect(() => {
    if (!chat) return;
    const key = roomNotificationKey(chat);
    useNotificationStore.getState().setActiveChatRoomId(chat.chatsId ?? key);
    useNotificationStore.getState().markRoomSeen(key);
    if (chat.chatsId) {
      useNotificationStore.getState().markRoomSeen(chat.chatsId);
    }
  }, [chat?.chatsId, chat?.senderId, chat?.receiverId, chat?.videoId]);

  useEffect(() => {
    if (!chat?.chatsId) return;
    return listenMessages(
      chat.chatsId,
      (list) => setMessages([...list].reverse()),
      (err) => setError(err.message),
    );
  }, [chat?.chatsId]);

  // Flutter: generateThumbnail(messageData) when chat media exists
  useEffect(() => {
    let cancelled = false;
    const url = chat?.messageData;
    if (!url) {
      setVideoThumb(null);
      return;
    }
    // Image reply — use the image itself as thumbnail
    if (/\.(jpe?g|png|webp|gif)(\?|$)/i.test(url) || url.includes('/image/')) {
      setVideoThumb(url);
      setThumbLoading(false);
      return;
    }
    setThumbLoading(true);
    generateVideoThumbnail(url)
      .then((thumb) => {
        if (!cancelled) setVideoThumb(thumb);
      })
      .finally(() => {
        if (!cancelled) setThumbLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [chat?.messageData]);

  const otherUserId =
    inferredSecondUserId ||
    (String(chat?.senderId ?? '') === myId
      ? String(chat?.receiverId ?? '')
      : String(chat?.senderId ?? '')) ||
    '';

  const iAmSender = String(chat?.senderId ?? '') === myId;
  const myStatus = chat?.myStatus ?? '';
  const otherStatus = chat?.otherStatus ?? '';
  /** Receiver must Accept; sender waits until otherStatus is Accepted. */
  const connectionAccepted = iAmSender
    ? otherStatus === 'Accepted'
    : myStatus === 'Accepted';
  const connectionRejected = iAmSender
    ? otherStatus === 'Rejected'
    : myStatus === 'Rejected';
  const showAcceptDecline = !!chat && !iAmSender && myStatus === 'Pending';
  const showWaitingBanner = !!chat && iAmSender && otherStatus === 'Pending';
  const canChat = !!chat?.chatsId && connectionAccepted;

  function onRecordVideoReply() {
    if (!myId || !otherUserId || !videoId) {
      Alert.alert('Error', 'Missing user session or video id.');
      return;
    }
    // Flutter: Get.to(CameraScreen(..., fromMessage: true, onSend: ...))
    router.push({
      pathname: '/chat/camera',
      params: {
        secondUserId: otherUserId,
        userName,
        description,
        userAvatar,
        bio,
        videoId: String(videoId),
        tags: tags.join(''),
      },
    });
  }

  async function onAccept() {
    if (!chat?.senderId || !myId) return;
    setBusy(true);
    try {
      await updateAcceptanceStatus({
        myUserId: myId,
        secondUserId: String(chat.senderId),
        videoId,
        status: 'Accepted',
      });
      notify('Connection accepted', { kind: 'success', title: 'Connected' });
      useNotificationStore.getState().markRoomSeen(roomNotificationKey(chat));
      await refresh();
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Failed to accept');
    } finally {
      setBusy(false);
    }
  }

  async function onDecline() {
    // Flutter: always update against the request sender (senderId)
    const requesterId = chat?.senderId ? String(chat.senderId) : '';
    if (!myId || !requesterId) {
      Alert.alert('Error', 'Missing requester info.');
      return;
    }
    setBusy(true);
    try {
      await updateAcceptanceStatus({
        myUserId: myId,
        secondUserId: requesterId,
        videoId,
        status: 'Rejected',
      });
      notify('Connection declined', { kind: 'warning', title: 'Declined' });
      useNotificationStore.getState().markRoomSeen(roomNotificationKey(chat ?? { videoId }));
      await refresh();
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Failed to decline');
    } finally {
      setBusy(false);
    }
  }

  /** Flutter composer gate: only message after the connection is accepted. */
  function assertCanMessage(): boolean {
    if (!chat?.chatsId) {
      Alert.alert('', 'Record a video reply first to start the conversation.');
      return false;
    }
    if (connectionRejected) {
      Alert.alert('', 'Chat request rejected');
      return false;
    }
    if (!connectionAccepted) {
      Alert.alert('', 'The Person has not accepted your request');
      return false;
    }
    return true;
  }

  async function onSend() {
    if (!text.trim() || !myId || !otherUserId) return;
    if (!assertCanMessage() || !chat?.chatsId) return;
    const message = text.trim();
    setText('');
    try {
      await sendTextMessage({
        chatRoomId: chat.chatsId,
        from: myId,
        to: otherUserId,
        message,
        videoId,
      });
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Failed to send');
      setText(message);
    }
  }

  function requireChatRoom() {
    if (!assertCanMessage() || !chat?.chatsId || !myId || !otherUserId) {
      return null;
    }
    return {
      chatsId: chat.chatsId,
      from: myId,
      to: otherUserId,
      videoId,
    };
  }

  async function runAttach(action: () => Promise<void>) {
    setUploadingAttach(true);
    setBusy(true);
    try {
      await action();
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Failed to send attachment');
    } finally {
      setBusy(false);
      setUploadingAttach(false);
    }
  }

  /** Close attach sheet, wait for Modal to clear, then run (needed for system pickers). */
  function afterSheetClose(action: () => void) {
    setAttachVisible(false);
    setAttachMode('attach');
    setTimeout(action, Platform.OS === 'ios' ? 550 : 300);
  }

  function onPickDocument() {
    const ctx = requireChatRoom();
    if (!ctx) return;
    afterSheetClose(() => {
      void (async () => {
        let doc;
        try {
          doc = await pickOfficeDocument();
        } catch (e) {
          Alert.alert(
            'Document',
            e instanceof Error ? e.message : 'Failed to open document picker.',
          );
          return;
        }
        if (!doc) return;

        setUploadingAttach(true);
        setBusy(true);
        try {
          await sendOfficeDocument(ctx, doc);
        } catch (e) {
          Alert.alert(
            'Document',
            e instanceof Error ? e.message : 'Failed to upload document.',
          );
        } finally {
          setBusy(false);
          setUploadingAttach(false);
        }
      })();
    });
  }

  async function startVoiceRecord() {
    const ctx = requireChatRoom();
    if (!ctx) {
      micHeldRef.current = false;
      return;
    }
    try {
      const perm = await requestRecordingPermissionsAsync();
      if (!perm.granted) {
        micHeldRef.current = false;
        Alert.alert('', 'Microphone permission is required for voice messages.');
        return;
      }
      if (!micHeldRef.current) return;

      await setAudioModeAsync({
        allowsRecording: true,
        playsInSilentMode: true,
        interruptionMode: 'duckOthers',
      });
      await audioRecorder.prepareToRecordAsync();
      if (!micHeldRef.current) {
        try {
          await setAudioModeAsync({
            allowsRecording: false,
            playsInSilentMode: true,
            interruptionMode: 'mixWithOthers',
          });
        } catch {
          // ignore
        }
        return;
      }

      audioRecorder.record();
      recordingActiveRef.current = true;
      finishingVoiceRef.current = false;
      recordStartedAt.current = Date.now();
      setRecordingUi(true);
    } catch (e) {
      micHeldRef.current = false;
      recordingActiveRef.current = false;
      setRecordingUi(false);
      Alert.alert('Error', e instanceof Error ? e.message : 'Unable to start recording');
    }
  }

  async function finishVoiceRecord(send: boolean) {
    // Ignore duplicate pressOut / cancel while already finishing
    if (finishingVoiceRef.current) return;
    finishingVoiceRef.current = true;
    micHeldRef.current = false;

    const wasRecording = recordingActiveRef.current;
    recordingActiveRef.current = false;
    setRecordingUi(false);

    const elapsedMs = wasRecording
      ? Math.max(
          recorderState.durationMillis ?? 0,
          Date.now() - recordStartedAt.current,
        )
      : 0;
    const elapsed = elapsedMs / 1000;

    let uri: string | null = null;
    if (wasRecording) {
      try {
        await audioRecorder.stop();
        // File is flushed after stop; uri is set on the recorder
        uri = audioRecorder.uri;
        if (!uri) {
          await new Promise((r) => setTimeout(r, 80));
          uri = audioRecorder.uri;
        }
      } catch {
        uri = audioRecorder.uri;
      }
    }

    try {
      await setAudioModeAsync({
        allowsRecording: false,
        playsInSilentMode: true,
        interruptionMode: 'mixWithOthers',
      });
    } catch {
      // ignore
    }

    if (!send || !wasRecording) {
      finishingVoiceRef.current = false;
      return;
    }

    const ctx = requireChatRoom();
    if (!uri || !ctx) {
      finishingVoiceRef.current = false;
      if (!uri) Alert.alert('Voice', 'Recording file was empty. Please try again.');
      return;
    }
    if (elapsed < 0.8) {
      finishingVoiceRef.current = false;
      Alert.alert('', 'Hold a bit longer to record a voice message.');
      return;
    }

    setSendingVoice(true);
    setBusy(true);
    try {
      await sendRecordedVoice(ctx, uri, elapsed);
    } catch (e) {
      Alert.alert(
        'Voice',
        e instanceof Error ? e.message : 'Failed to send voice message',
      );
    } finally {
      setBusy(false);
      setSendingVoice(false);
      finishingVoiceRef.current = false;
    }
  }

  const showSend = text.trim().length > 0;

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'bottom']}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <View style={styles.appBar}>
          <Pressable
            style={styles.circleBtn}
            onPress={() => {
              if (router.canGoBack()) router.back();
              else router.replace('/(tabs)');
            }}
          >
            <MaterialIcons name="arrow-back-ios-new" size={20} color={Brand.primaryIconColor} />
          </Pressable>
          <View style={styles.flex} />
          <Pressable
            style={styles.circleBtn}
            onPress={() =>
              router.push({
                pathname: '/chat/rate',
                params: {
                  userAvatar,
                  videoId: String(videoId),
                  name: userName,
                  bio,
                },
              })
            }
          >
            <Image
              source={require('../../assets/images/ic_support.png')}
              style={styles.supportIcon}
              resizeMode="contain"
            />
          </Pressable>
        </View>

        <ScrollView
          contentContainerStyle={styles.content}
          keyboardShouldPersistTaps="handled"
          style={styles.chatScroll}
        >
          <View style={styles.headerRow}>
            <UserAvatar uri={userAvatar} radius={35} />
            <Text style={styles.userName}>@{userName}</Text>
          </View>

          <View style={styles.divider} />

          <View style={styles.descCard}>
            <Text style={styles.descText}>{description}</Text>
            {tags.length > 0 ? (
              <View style={styles.tagsRow}>
                {tags.map((t, i) => (
                  <HashtagChip key={`${t}-${i}`} label={t} />
                ))}
              </View>
            ) : null}
          </View>

          {error ? <Text style={styles.error}>{error}</Text> : null}

          {loading ? (
            <ActivityIndicator color={Brand.primary} style={{ marginTop: 24 }} />
          ) : !chat ? (
            /* Flutter: Row → UserAvatarImage + Expanded grey[200] record box */
            <View style={styles.replyRow}>
              <UserAvatar uri={userAvatar} radius={20} />
              <Pressable
                style={styles.recordBox}
                onPress={onRecordVideoReply}
                disabled={busy}
              >
                <Text style={styles.recordText}>
                  Record Video Reply to connect with {userName}
                </Text>
                <View style={styles.camBadge}>
                  <MaterialIcons name="videocam" size={24} color="#FFFFFF" />
                </View>
              </Pressable>
            </View>
          ) : (
            <View style={[styles.existingWrap, !iAmSender && { alignItems: 'flex-end' }]}>
              <View style={styles.videoRow}>
                {iAmSender ? <UserAvatar uri={me?.avatar ?? undefined} /> : null}
                <Pressable
                  style={styles.thumb}
                  onPress={() => {
                    const mediaUrl = (chat.messageData ?? '').trim();
                    if (!mediaUrl) {
                      Alert.alert('', 'No media available for this chat.');
                      return;
                    }
                    const isImg =
                      /\.(jpe?g|png|webp|gif)(\?|$)/i.test(mediaUrl) ||
                      mediaUrl.includes('/image/') ||
                      mediaUrl.includes('/storage/images/');
                    // Never put Storage/AWS URLs in router params — Expo Router
                    // decodes `%2F` and breaks playback. Use the media store.
                    openChatMedia(mediaUrl, {
                      isImage: isImg,
                      edits:
                        chat.messageEdits ??
                        useMediaOverlayStore.getState().get(mediaUrl),
                    });
                    if (chat.messageEdits && mediaUrl) {
                      useMediaOverlayStore
                        .getState()
                        .remember(mediaUrl, chat.messageEdits);
                    }
                    router.push('/chat/video');
                  }}
                >
                  {videoThumb ? (
                    <Image
                      source={{ uri: videoThumb }}
                      style={styles.thumbImage}
                      resizeMode="cover"
                    />
                  ) : thumbLoading ? (
                    <ActivityIndicator color={Brand.white} />
                  ) : null}
                  {!(
                    chat.messageData &&
                    (/\.(jpe?g|png|webp|gif)(\?|$)/i.test(chat.messageData) ||
                      chat.messageData.includes('/image/'))
                  ) ? (
                    <View style={styles.thumbPlay}>
                      <MaterialIcons name="play-arrow" size={36} color="#fff" />
                    </View>
                  ) : null}
                </Pressable>
                {!iAmSender ? <UserAvatar uri={userAvatar} /> : null}
              </View>

              {showAcceptDecline ? (
                <View style={styles.acceptRow}>
                  <Pressable style={styles.acceptBtn} onPress={onAccept} disabled={busy}>
                    <Text style={styles.acceptText}>Accept Connection</Text>
                  </Pressable>
                  <Pressable style={styles.declineBtn} onPress={onDecline} disabled={busy}>
                    <Text style={styles.declineText}>Decline</Text>
                  </Pressable>
                </View>
              ) : null}

              {showWaitingBanner ? (
                <View style={styles.statusBanner}>
                  <MaterialIcons name="hourglass-top" size={16} color={Brand.primary} />
                  <Text style={styles.statusBannerText}>
                    Waiting for {userName || 'them'} to accept your connection
                  </Text>
                </View>
              ) : null}

              {connectionRejected ? (
                <View style={[styles.statusBanner, styles.statusBannerRejected]}>
                  <MaterialIcons name="block" size={16} color={Brand.primary} />
                  <Text style={styles.statusBannerText}>
                    {iAmSender
                      ? 'Your connection request was declined'
                      : 'You declined this connection'}
                  </Text>
                </View>
              ) : null}
            </View>
          )}

          {messages.map((m) => {
            // Flutter: own messages LEFT, other RIGHT (check = from == me → topLeft)
            const mine = String(m.from) === myId;
            const timeLabel = formatRelativeChatTime(m.timestamp);
            return (
              <View
                key={m.id}
                style={[
                  styles.msgBlock,
                  mine ? styles.msgBlockMine : styles.msgBlockTheirs,
                ]}
              >
                <View style={styles.msgRow}>
                  {mine ? (
                    <UserAvatar uri={me?.avatar ?? undefined} radius={20} />
                  ) : null}
                  {mine ? <View style={{ width: 5 }} /> : null}
                  <ChatMessageBubble message={m} mine={mine} />
                  {!mine ? <View style={{ width: 5 }} /> : null}
                  {!mine ? <UserAvatar uri={userAvatar} radius={20} /> : null}
                </View>
                {timeLabel ? (
                  <Text
                    style={[
                      styles.msgTime,
                      mine ? styles.msgTimeMine : styles.msgTimeTheirs,
                    ]}
                  >
                    {timeLabel}
                  </Text>
                ) : null}
              </View>
            );
          })}
        </ScrollView>

        {busy || uploadingAttach || sendingVoice ? (
          <View style={styles.busyBar}>
            <ActivityIndicator color={Brand.primary} />
            <Text style={styles.busyText}>
              {sendingVoice
                ? 'Sending voice message…'
                : uploadingAttach
                  ? 'Uploading…'
                  : 'Talking to backend…'}
            </Text>
          </View>
        ) : null}

        {recordingUi ? (
          <View style={styles.recordingBanner}>
            <MaterialIcons name="fiber-manual-record" size={18} color={Brand.primary} />
            <Text style={styles.recordingText}>
              {Math.floor((recorderState.durationMillis ?? 0) / 60000)}:
              {String(Math.floor(((recorderState.durationMillis ?? 0) / 1000) % 60)).padStart(2, '0')}
              {'  Release to send'}
            </Text>
            <Pressable onPress={() => void finishVoiceRecord(false)} hitSlop={10}>
              <MaterialIcons name="delete" size={22} color={Brand.primary} />
            </Pressable>
          </View>
        ) : null}

        <View style={styles.composer}>
          <Pressable
            style={styles.attachBtn}
            onPress={() => {
              if (!canChat) {
                if (!assertCanMessage()) return;
                return;
              }
              setAttachMode('attach');
              setAttachVisible(true);
            }}
          >
            <MaterialIcons name="attach-file" size={24} color="#9E9E9E" />
          </Pressable>

          <TextInput
            style={styles.input}
            placeholder={recordingUi ? 'Recording…' : 'Type as message...'}
            placeholderTextColor="#9E9E9E"
            value={text}
            onChangeText={setText}
            editable={!recordingUi && !sendingVoice}
            multiline
            textAlignVertical="center"
          />

          <View style={{ width: 10 }} />

          {showSend && !recordingUi ? (
            <Pressable style={styles.sendOuter} onPress={onSend}>
              <View style={styles.sendInner}>
                <MaterialIcons name="send" size={20} color={Brand.white} />
              </View>
            </Pressable>
          ) : (
            <Pressable
              style={[styles.micBtn, recordingUi && styles.micBtnActive]}
              disabled={sendingVoice}
              onPressIn={() => {
                if (!canChat) {
                  void assertCanMessage();
                  return;
                }
                if (sendingVoice || finishingVoiceRef.current) return;
                micHeldRef.current = true;
                void startVoiceRecord();
              }}
              onPressOut={() => {
                void finishVoiceRecord(true);
              }}
            >
              <MaterialIcons
                name="mic"
                size={24}
                color={Brand.white}
              />
            </Pressable>
          )}
        </View>

        <ChatAttachmentSheet
          visible={attachVisible}
          mode={attachMode}
          onClose={() => {
            setAttachVisible(false);
            setAttachMode('attach');
          }}
          onDocument={() => onPickDocument()}
          onGallery={() => setAttachMode('gallery')}
          onLocation={() =>
            afterSheetClose(() => {
              const ctx = requireChatRoom();
              if (!ctx) return;
              router.push({
                pathname: '/chat/location',
                params: {
                  chatsId: ctx.chatsId,
                  from: ctx.from,
                  to: ctx.to,
                  videoId: String(ctx.videoId),
                },
              });
            })
          }
          onPhotos={() =>
            afterSheetClose(() => {
              void runAttach(async () => {
                const ctx = requireChatRoom();
                if (!ctx) return;
                await pickAndSendPhotos(ctx);
              });
            })
          }
          onVideos={() =>
            afterSheetClose(() => {
              void runAttach(async () => {
                const ctx = requireChatRoom();
                if (!ctx) return;
                await pickAndSendGalleryVideo(ctx);
              });
            })
          }
        />
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Brand.white },
  flex: { flex: 1 },
  chatScroll: { flex: 1, backgroundColor: Brand.white },
  appBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 5,
    paddingVertical: 5,
    minHeight: 70,
  },
  circleBtn: {
    margin: 8,
    padding: 10,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: Brand.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  supportIcon: { width: 20, height: 20 },
  content: {
    paddingBottom: 100,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  userName: {
    marginLeft: 10,
    fontSize: 18,
    fontWeight: '700',
    fontFamily: 'SF-Pro-Display',
    color: Brand.black,
  },
  divider: {
    height: 0.5,
    backgroundColor: Brand.border,
    marginHorizontal: 16,
  },
  // Flutter: padding 16, margin fromLTRB(16,5,16,15) — height grows with text + tags
  descCard: {
    alignSelf: 'flex-start',
    maxWidth: '90%',
    marginLeft: 16,
    marginRight: 16,
    marginTop: 5,
    marginBottom: 15,
    padding: 16,
    backgroundColor: Brand.primaryBottom,
    borderRadius: 16,
  },
  descText: {
    color: Brand.white,
    fontSize: 16,
    fontWeight: '400',
    lineHeight: 22,
  },
  tagsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-start',
    marginTop: 10,
  },
  chip: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 20,
    marginRight: 6,
    marginBottom: 4,
    backgroundColor: 'rgba(0,0,0,0.1)',
    flexShrink: 0,
  },
  chipText: {
    color: Brand.white,
    fontSize: 14,
  },
  error: {
    color: Brand.primary,
    marginHorizontal: 16,
    marginBottom: 8,
    fontSize: 13,
  },
  replyRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
  },
  // Flutter: Colors.grey[200], padding 16, radius 16
  recordBox: {
    flex: 1,
    marginLeft: 10,
    padding: 16,
    backgroundColor: '#EEEEEE',
    borderRadius: 16,
    flexDirection: 'row',
    alignItems: 'center',
  },
  recordText: {
    flex: 1,
    color: Brand.black,
    fontSize: 14,
    fontWeight: '400',
    paddingRight: 8,
  },
  // Flutter: Colors.grey circular badge + Icons.videocam (white)
  camBadge: {
    backgroundColor: '#9E9E9E',
    borderRadius: 1000,
    padding: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  existingWrap: { paddingHorizontal: 16 },
  videoRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 5 },
  thumb: {
    width: 90,
    height: 100,
    borderRadius: 10,
    backgroundColor: Brand.bgGrey,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  thumbImage: {
    ...StyleSheet.absoluteFill,
    width: 90,
    height: 100,
  },
  thumbPlay: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0,0,0,0.25)',
  },
  acceptRow: { flexDirection: 'row', marginTop: 8, gap: 10 },
  statusBanner: {
    marginTop: 10,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: 'rgba(239,39,77,0.08)',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
    maxWidth: 320,
  },
  statusBannerRejected: {
    backgroundColor: 'rgba(140,140,140,0.12)',
  },
  statusBannerText: {
    flex: 1,
    fontSize: 13,
    color: Brand.textPrimary,
    fontWeight: '500',
  },
  acceptBtn: {
    backgroundColor: Brand.primary,
    borderRadius: 10,
    padding: 8,
  },
  acceptText: { color: Brand.white, fontSize: 12, fontWeight: '500' },
  declineBtn: {
    backgroundColor: 'rgba(48,48,48,0.3)',
    borderRadius: 10,
    padding: 8,
  },
  declineText: { fontSize: 12, fontWeight: '500', color: Brand.black },
  bubbleRow: {
    paddingHorizontal: 12,
    marginTop: 3,
    marginBottom: 3,
    width: '100%',
  },
  bubbleMine: { alignItems: 'flex-end' },
  bubbleTheirs: { alignItems: 'flex-start' },
  dayChipWrap: {
    alignItems: 'center',
    marginVertical: 12,
  },
  dayChip: {
    backgroundColor: '#E8E8E8',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 8,
  },
  dayChipText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#667781',
  },
  msgBlock: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    width: '100%',
  },
  msgBlockMine: { alignItems: 'flex-start' },
  msgBlockTheirs: { alignItems: 'flex-end' },
  msgRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    maxWidth: '100%',
  },
  msgTime: {
    marginTop: 5,
    color: '#9E9E9E',
    fontSize: 12,
  },
  msgTimeMine: { alignSelf: 'flex-start', textAlign: 'left' },
  msgTimeTheirs: { alignSelf: 'flex-end', textAlign: 'right' },
  composer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingRight: 10,
    paddingLeft: 4,
    paddingVertical: 10,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: Brand.border,
  },
  recordingBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginHorizontal: 10,
    marginBottom: 4,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: Brand.txtGrey,
    backgroundColor: Brand.white,
  },
  recordingText: { flex: 1, color: Brand.black, fontSize: 14, fontWeight: '500' },
  attachBtn: {
    width: 44,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sendOuter: {
    width: 52,
    height: 52,
    borderRadius: 26,
    borderWidth: 5,
    borderColor: 'rgba(236,82,112,0.4)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  sendInner: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Brand.primaryBottom,
    alignItems: 'center',
    justifyContent: 'center',
  },
  micBtn: {
    width: 45,
    height: 45,
    borderRadius: 23,
    backgroundColor: Brand.txtGrey,
    alignItems: 'center',
    justifyContent: 'center',
  },
  micBtnActive: {
    backgroundColor: Brand.primary,
  },
  input: {
    flex: 1,
    minHeight: 52,
    maxHeight: 120,
    borderWidth: 1,
    borderColor: Brand.border,
    borderRadius: 1000,
    paddingHorizontal: 14,
    paddingVertical: 14,
    color: Brand.black,
    fontSize: 15,
    lineHeight: 20,
  },
  sideBtn: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  recordingDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: Brand.primary,
  },
  busyBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    paddingVertical: 8,
  },
  busyText: { color: Brand.txtGrey, fontSize: 13 },
});
