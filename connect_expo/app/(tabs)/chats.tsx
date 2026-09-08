/**
 * Flutter `ChatScreen` (all_chats.dart): search, My Replies / My videos, room list.
 */
import { Brand } from '@/constants/Colors';
import { ChatStoriesRow } from '@/components/ChatStoriesRow';
import { listenChatRooms, type ChatDataModel } from '@/services/chat';
import { useAuthStore } from '@/store/authStore';
import { useNotificationStore } from '@/store/notificationStore';
import { formatRelativeChatTime, parseMessageDate } from '@/utils/chatTime';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router } from 'expo-router';
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
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const TABS = ['My Replies', 'My videos'] as const;

function roomAvatar(room: ChatDataModel) {
  return room.avatar ?? '';
}

function openRoom(room: ChatDataModel, myId: string) {
  const senderId = room.senderId ? String(room.senderId) : '';
  const receiverId = room.receiverId ? String(room.receiverId) : '';
  const otherId = senderId === myId ? receiverId : senderId;

  const tagsRaw = room.tags ?? '';
  const tags = tagsRaw.includes('#')
    ? tagsRaw
        .split('#')
        .filter(Boolean)
        .map((t) => (t.startsWith('#') ? t : `#${t}`))
        .join(',')
    : tagsRaw;

  router.push({
    pathname: '/chat/[videoId]',
    params: {
      videoId: String(room.videoId ?? ''),
      secondUserId: otherId,
      userName: room.userName ?? '',
      description: room.description ?? '',
      userAvatar: roomAvatar(room),
      tags,
      chatsId: room.chatsId ?? '',
      senderId,
      receiverId,
      myStatus: room.myStatus ?? '',
      otherStatus: room.otherStatus ?? '',
      messageData: room.messageData ?? '',
    },
  });
}

export default function ChatsScreen() {
  const insets = useSafeAreaInsets();
  const me = useAuthStore((s) => s.user);
  const myId = me?.id != null ? String(me.id) : '';
  const badgeCount = useNotificationStore((s) => s.badgeCount);

  const [search, setSearch] = useState('');
  const [tab, setTab] = useState<0 | 1>(0);
  const [rooms, setRooms] = useState<ChatDataModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!myId) {
      setLoading(false);
      setRooms([]);
      return;
    }
    // Keep previous list visible while switching tabs — avoids layout jump / gap
    setError(null);
    setLoading((prev) => (rooms.length === 0 ? true : prev));
    const unsub = listenChatRooms(
      myId,
      tab,
      (data) => {
        setRooms(data);
        setLoading(false);
      },
      (err) => {
        setError(err.message || 'Something went wrong');
        setLoading(false);
      },
    );
    return unsub;
    // eslint-disable-next-line react-hooks/exhaustive-deps -- only rebind on user/tab
  }, [myId, tab]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    const list = !q
      ? rooms
      : rooms.filter((r) => {
          const hay = `${r.userName ?? ''} ${r.description ?? ''} ${r.tags ?? ''}`.toLowerCase();
          return hay.includes(q);
        });
    // Keep newest conversations first (by lastMessageTime)
    return [...list].sort((a, b) => {
      const ta = parseMessageDate(a.lastMessageTime)?.getTime() ?? 0;
      const tb = parseMessageDate(b.lastMessageTime)?.getTime() ?? 0;
      return tb - ta;
    });
  }, [rooms, search]);

  return (
    <View style={[styles.safe, { paddingTop: insets.top }]}>
      <View style={styles.appBar}>
        <Text style={styles.appBarTitle}>Chats</Text>
        <Pressable
          style={styles.bellBtn}
          onPress={() => router.push('/notifications')}
          hitSlop={10}
          accessibilityLabel="Notifications"
        >
          <MaterialIcons name="notifications-none" size={24} color={Brand.primaryIconColor} />
          {badgeCount > 0 ? (
            <View style={styles.bellBadge}>
              <Text style={styles.bellBadgeText}>
                {badgeCount > 99 ? '99+' : badgeCount}
              </Text>
            </View>
          ) : null}
        </Pressable>
      </View>

      <View style={styles.body}>
        <View style={styles.searchWrap}>
          <TextInput
            style={styles.search}
            placeholder="Search Chats"
            placeholderTextColor={Brand.textLight}
            value={search}
            onChangeText={setSearch}
          />
          <MaterialIcons name="search" size={22} color={Brand.textLight} />
        </View>

        <ChatStoriesRow />

        <View style={styles.tabs}>
          {TABS.map((label, index) => {
            const active = tab === index;
            return (
              <Pressable
                key={label}
                onPress={() => setTab(index as 0 | 1)}
                style={[styles.tab, active && styles.tabActive]}
              >
                <Text style={[styles.tabText, active && styles.tabTextActive]}>{label}</Text>
              </Pressable>
            );
          })}
        </View>

        <View style={styles.listWrap}>
          {loading && filtered.length === 0 ? (
            <View style={styles.center}>
              <ActivityIndicator color={Brand.primary} />
            </View>
          ) : error ? (
            <View style={styles.center}>
              <Text style={styles.empty}>{error}</Text>
            </View>
          ) : filtered.length === 0 ? (
            <View style={styles.center}>
              <Text style={styles.empty}>No chats</Text>
            </View>
          ) : (
            <FlatList
              data={filtered}
              keyExtractor={(item, i) =>
                `${item.chatsId ?? ''}-${item.videoId ?? ''}-${item.senderId ?? ''}-${i}`
              }
              contentContainerStyle={styles.list}
              renderItem={({ item }) => {
                const pending =
                  tab === 1 && item.myStatus === 'Pending';
                const waiting =
                  tab === 0 && item.otherStatus === 'Pending';
                return (
                <Pressable style={styles.row} onPress={() => openRoom(item, myId)}>
                  <View>
                    <Image
                      source={
                        roomAvatar(item)
                          ? { uri: roomAvatar(item) }
                          : require('../../assets/images/ic_person.png')
                      }
                      style={styles.avatar}
                    />
                    {pending ? <View style={styles.pendingDot} /> : null}
                  </View>
                  <View style={styles.rowBody}>
                    <View style={styles.rowTitle}>
                      <Text style={styles.desc} numberOfLines={2}>
                        {item.description || item.userName || 'Chat'}
                      </Text>
                      {pending ? (
                        <View style={styles.pendingChip}>
                          <Text style={styles.pendingChipText}>Accept</Text>
                        </View>
                      ) : waiting ? (
                        <View style={[styles.pendingChip, styles.waitingChip]}>
                          <Text style={[styles.pendingChipText, styles.waitingChipText]}>
                            Pending
                          </Text>
                        </View>
                      ) : null}
                    </View>
                    {item.tags ? (
                      <Text style={styles.tags} numberOfLines={1}>
                        {item.tags}
                      </Text>
                    ) : null}
                    <Text style={styles.time}>
                      {formatRelativeChatTime(item.lastMessageTime) || 'just Now'}
                    </Text>
                  </View>
                </Pressable>
                );
              }}
            />
          )}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Brand.white },
  appBar: {
    height: 52,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: Brand.borderLight,
  },
  appBarTitle: {
    flex: 1,
    textAlign: 'center',
    fontSize: 18,
    fontWeight: '700',
    color: Brand.textPrimary,
    marginLeft: 40,
  },
  bellBtn: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  bellBadge: {
    position: 'absolute',
    top: 4,
    right: 2,
    minWidth: 16,
    height: 16,
    borderRadius: 8,
    paddingHorizontal: 4,
    backgroundColor: Brand.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  bellBadgeText: {
    color: Brand.white,
    fontSize: 10,
    fontWeight: '700',
  },
  body: { flex: 1, paddingHorizontal: 16 },
  searchWrap: {
    marginTop: 10,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Brand.border,
    borderRadius: 12,
    paddingHorizontal: 12,
    minHeight: 48,
  },
  search: {
    flex: 1,
    fontSize: 15,
    color: Brand.textPrimary,
    paddingVertical: 10,
  },
  tabs: {
    height: 48,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 15,
    marginTop: 4,
  },
  tab: {
    paddingHorizontal: 7,
    paddingVertical: 4,
    borderBottomWidth: 2,
    borderBottomColor: 'transparent',
  },
  tabActive: { borderBottomColor: Brand.primary },
  tabText: { fontSize: 12, color: Brand.txtGrey, fontWeight: '400' },
  tabTextActive: { color: Brand.primary, fontWeight: '700' },
  list: { paddingTop: 4, paddingBottom: 24 },
  listWrap: { flex: 1 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 13,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'rgba(0,0,0,0.06)',
  },
  avatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    marginRight: 10,
    backgroundColor: Brand.borderLight,
  },
  rowBody: { flex: 1 },
  rowTitle: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 8,
  },
  desc: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: Brand.textPrimary,
  },
  pendingDot: {
    position: 'absolute',
    right: 10,
    top: 0,
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: Brand.primary,
    borderWidth: 2,
    borderColor: Brand.white,
  },
  pendingChip: {
    backgroundColor: Brand.primary,
    borderRadius: 8,
    paddingHorizontal: 8,
    paddingVertical: 3,
  },
  pendingChipText: {
    color: Brand.white,
    fontSize: 11,
    fontWeight: '700',
  },
  waitingChip: {
    backgroundColor: 'rgba(140,140,140,0.15)',
  },
  waitingChipText: {
    color: Brand.txtGrey,
  },
  tags: {
    marginTop: 2,
    fontSize: 13,
    color: Brand.primary,
  },
  time: {
    marginTop: 2,
    fontSize: 12,
    color: 'rgba(0,0,0,0.75)',
  },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  empty: { fontSize: 16, color: Brand.textLight, fontWeight: '600' },
});
