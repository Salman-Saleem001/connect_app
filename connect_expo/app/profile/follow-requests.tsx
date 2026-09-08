/**
 * Flutter `FollowRequestsScreen` — people who sent a video reply / connect
 * request on one of my profile videos.
 */
import { ScreenAppBar } from '@/components/ScreenAppBar';
import { Brand } from '@/constants/Colors';
import {
  listenVideoFollowRequests,
  updateAcceptanceStatus,
  type ChatDataModel,
} from '@/services/chat';
import { useAuthStore } from '@/store/authStore';
import {
  notify,
  roomNotificationKey,
  useNotificationStore,
} from '@/store/notificationStore';
import { formatRelativeChatTime, parseMessageDate } from '@/utils/chatTime';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  Image,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

function requestTimeLabel(room: ChatDataModel) {
  const fromTime = formatRelativeChatTime(room.lastMessageTime);
  if (fromTime) return fromTime;
  const parsed = parseMessageDate(room.videoTime);
  if (parsed) return formatRelativeChatTime(parsed) || '';
  const type = room.lastMessageType;
  return type ? String(type) : '';
}

export default function FollowRequestsScreen() {
  const params = useLocalSearchParams<{
    videoId?: string;
    thumbnail?: string;
    name?: string;
    viewsCount?: string;
  }>();
  const videoId = Number(params.videoId ?? 0);
  const thumbnail = typeof params.thumbnail === 'string' ? params.thumbnail : '';
  const name = typeof params.name === 'string' ? params.name : '';
  const viewsCount = Number(params.viewsCount ?? 0);
  const me = useAuthStore((s) => s.user);
  const myId = me?.id != null ? String(me.id) : '';

  const [rooms, setRooms] = useState<ChatDataModel[]>([]);
  const [queryText, setQueryText] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busyKey, setBusyKey] = useState<string | null>(null);

  useEffect(() => {
    if (!myId || !videoId) {
      setLoading(false);
      setError(!videoId ? 'Missing video id.' : 'Please login again.');
      return;
    }
    setLoading(true);
    setError(null);
    return listenVideoFollowRequests(
      myId,
      videoId,
      (list) => {
        setRooms(list);
        setLoading(false);
      },
      (err) => {
        setError(err.message || 'Something went wrong');
        setLoading(false);
      },
    );
  }, [myId, videoId]);

  const filtered = useMemo(() => {
    const q = queryText.trim().toLowerCase();
    if (!q) return rooms;
    return rooms.filter((r) => (r.userName ?? '').toLowerCase().includes(q));
  }, [rooms, queryText]);

  async function onAccept(item: ChatDataModel) {
    if (!myId || !item.senderId) return;
    const key = roomNotificationKey(item);
    setBusyKey(key);
    try {
      await updateAcceptanceStatus({
        myUserId: myId,
        secondUserId: String(item.senderId),
        videoId,
        status: 'Accepted',
      });
      notify('Connection accepted', { title: 'Connected', kind: 'success' });
      useNotificationStore.getState().markRoomSeen(key);
    } finally {
      setBusyKey(null);
    }
  }

  async function onReject(item: ChatDataModel) {
    if (!myId || !item.senderId) return;
    const key = roomNotificationKey(item);
    setBusyKey(key);
    try {
      await updateAcceptanceStatus({
        myUserId: myId,
        secondUserId: String(item.senderId),
        videoId,
        status: 'Rejected',
      });
      notify('Connection declined', { title: 'Declined', kind: 'warning' });
      useNotificationStore.getState().markRoomSeen(key);
    } finally {
      setBusyKey(null);
    }
  }

  function openChat(item: ChatDataModel) {
    const avatar = item.userAvatar || item.avatar || '';
    router.push({
      pathname: '/chat/[videoId]',
      params: {
        videoId: String(item.videoId ?? videoId),
        secondUserId: String(item.senderId ?? ''),
        userName: item.userName ?? '',
        userAvatar: avatar,
        description: item.description ?? '',
        tags: item.tags ?? '',
        chatsId: item.chatsId ?? '',
        senderId: String(item.senderId ?? ''),
        receiverId: String(item.receiverId ?? myId),
        myStatus: item.myStatus ?? 'Accepted',
        messageData: item.messageData ?? '',
      },
    });
  }

  return (
    <View style={styles.root}>
      <ScreenAppBar title="Follow Requests" />
      <FlatList
        data={filtered}
        keyExtractor={(item, i) =>
          `${item.chatsId ?? item.senderId ?? i}-${item.videoId ?? 0}`
        }
        contentContainerStyle={styles.content}
        ListHeaderComponent={
          <View>
            <View style={styles.header}>
              {thumbnail && /^https?:\/\//i.test(thumbnail) ? (
                <Image source={{ uri: thumbnail }} style={styles.thumb} />
              ) : (
                <View style={[styles.thumb, styles.thumbFallback]}>
                  <MaterialIcons name="videocam" size={40} color={Brand.primary} />
                </View>
              )}
              <View style={styles.headerMeta}>
                <Text style={styles.title} numberOfLines={2}>
                  {name || 'Video'}
                </Text>
                <Text style={styles.username}>{me?.username ?? ''}</Text>
                <Text style={styles.views}>{viewsCount} views</Text>
              </View>
            </View>
            <View style={styles.search}>
              <TextInput
                value={queryText}
                onChangeText={setQueryText}
                placeholder="Search"
                placeholderTextColor={Brand.textLight}
                style={styles.searchInput}
              />
              <MaterialIcons name="search" size={20} color={Brand.textLight} />
            </View>
          </View>
        }
        ListEmptyComponent={
          loading ? (
            <ActivityIndicator color={Brand.primary} style={{ marginTop: 40 }} />
          ) : error ? (
            <Text style={styles.empty}>{error}</Text>
          ) : (
            <Text style={styles.empty}>No requests yet</Text>
          )
        }
        renderItem={({ item }) => {
          const accepted = item.myStatus === 'Accepted';
          const rejected = item.myStatus === 'Rejected';
          const avatar = item.userAvatar || item.avatar;
          const key = roomNotificationKey(item);
          const busy = busyKey === key;
          const when = requestTimeLabel(item);

          return (
            <View style={styles.card}>
              <View style={styles.cardTop}>
                {avatar && /^https?:\/\//i.test(avatar) ? (
                  <Image source={{ uri: avatar }} style={styles.avatar} />
                ) : (
                  <View style={[styles.avatar, styles.avatarFallback]}>
                    <MaterialIcons name="person" size={22} color={Brand.txtGrey} />
                  </View>
                )}
                <View style={{ flex: 1 }}>
                  <Text style={styles.cardName}>{item.userName || 'User'}</Text>
                  <View style={styles.locRow}>
                    <MaterialIcons name="location-on" size={14} color={Brand.txtGrey} />
                    <Text style={styles.locText} numberOfLines={1}>
                      {item.description?.trim() || '—'}
                    </Text>
                  </View>
                  {when ? (
                    <Text style={styles.cardTime}>commented {when}</Text>
                  ) : null}
                </View>
              </View>

              <View style={styles.cardActions}>
                {accepted ? (
                  <Pressable style={styles.messageBtn} onPress={() => openChat(item)}>
                    <Text style={styles.messageText}>Message</Text>
                  </Pressable>
                ) : rejected ? (
                  <Text style={styles.rejected}>Declined</Text>
                ) : (
                  <View style={styles.acceptRow}>
                    <Pressable
                      style={[styles.roundBtn, styles.accept, busy && styles.disabled]}
                      disabled={busy}
                      onPress={() => void onAccept(item)}
                    >
                      <MaterialIcons name="check" size={18} color={Brand.white} />
                    </Pressable>
                    <Pressable
                      style={[styles.roundBtn, styles.reject, busy && styles.disabled]}
                      disabled={busy}
                      onPress={() => void onReject(item)}
                    >
                      <MaterialIcons name="not-interested" size={18} color={Brand.white} />
                    </Pressable>
                  </View>
                )}
              </View>
            </View>
          );
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  content: { padding: 16, paddingBottom: 40 },
  header: { flexDirection: 'row', gap: 16 },
  thumb: {
    width: 120,
    height: 160,
    borderRadius: 8,
    backgroundColor: Brand.bgGrey,
  },
  thumbFallback: { alignItems: 'center', justifyContent: 'center' },
  headerMeta: { flex: 1, paddingTop: 4 },
  title: { fontSize: 20, fontWeight: '700', color: Brand.textPrimary },
  username: { marginTop: 4, color: Brand.txtGrey },
  views: { marginTop: 6, fontSize: 13, color: Brand.textLight },
  search: {
    marginTop: 16,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Brand.border,
    borderRadius: 12,
    paddingHorizontal: 12,
    minHeight: 48,
  },
  searchInput: {
    flex: 1,
    fontSize: 15,
    color: Brand.textPrimary,
    paddingVertical: 10,
  },
  empty: { textAlign: 'center', color: Brand.txtGrey, marginTop: 30 },
  card: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 10,
    paddingTop: 10,
    paddingRight: 8,
    paddingLeft: 10,
    paddingBottom: 8,
    marginVertical: 5,
  },
  cardTop: { flexDirection: 'row', alignItems: 'flex-start', gap: 12 },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Brand.bgGrey,
  },
  avatarFallback: { alignItems: 'center', justifyContent: 'center' },
  cardName: { fontSize: 16, fontWeight: '700', color: Brand.textPrimary },
  locRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginTop: 4,
  },
  locText: { flex: 1, fontSize: 14, color: Brand.textLight },
  cardTime: { fontSize: 12, color: Brand.txtGrey, marginTop: 4 },
  cardActions: {
    marginTop: 8,
    alignItems: 'flex-end',
  },
  acceptRow: { flexDirection: 'row', gap: 8 },
  roundBtn: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: 'center',
    justifyContent: 'center',
    margin: 4,
  },
  accept: { backgroundColor: Brand.green },
  reject: { backgroundColor: 'rgb(233,75,62)' },
  disabled: { opacity: 0.5 },
  messageBtn: {
    backgroundColor: Brand.green,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 10,
  },
  messageText: { color: Brand.white, fontWeight: '600', fontSize: 13 },
  rejected: { color: Brand.txtGrey, fontSize: 13, fontWeight: '600', margin: 8 },
});
