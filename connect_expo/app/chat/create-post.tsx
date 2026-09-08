/**
 * Flutter `CreatePostScreen` — caption, map location, tags, calendar expiry → Post.
 */
import { PrimaryButton } from '@/components/PrimaryButton';
import { TextField } from '@/components/TextField';
import { Brand } from '@/constants/Colors';
import { createPost, createTag, getTags } from '@/services/api/posts';
import { useAuthStore } from '@/store/authStore';
import { useFeedStore } from '@/store/feedStore';
import {
  appendMediaEditsToInfo,
  useMediaOverlayStore,
} from '@/store/mediaViewerStore';
import { notify } from '@/store/notificationStore';
import { usePostDraftStore } from '@/store/postDraftStore';
import { useProfileStore } from '@/store/profileStore';
import DateTimePicker, {
  type DateTimePickerEvent,
} from '@react-native-community/datetimepicker';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import * as Location from 'expo-location';
import { useVideoPlayer, VideoView } from 'expo-video';
import { router, useFocusEffect, useLocalSearchParams } from 'expo-router';
import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Image,
  Modal,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

function parseTagList(raw: unknown): string[] {
  if (Array.isArray(raw)) {
    return raw
      .map((t) => {
        if (typeof t === 'string') return t;
        if (t && typeof t === 'object' && 'name' in t) {
          return String((t as { name: unknown }).name);
        }
        return '';
      })
      .filter(Boolean);
  }
  if (raw && typeof raw === 'object') {
    const o = raw as Record<string, unknown>;
    if (Array.isArray(o.tags)) return parseTagList(o.tags);
    if (Array.isArray(o.data)) return parseTagList(o.data);
  }
  return [];
}

function formatYmd(d: Date) {
  return d.toISOString().slice(0, 10);
}

function extractPostedVideoUrl(result: unknown): string | null {
  if (!result || typeof result !== 'object') return null;
  const root = result as Record<string, unknown>;
  const candidates = [root, root.data, root.post, root.video].filter(
    (v): v is Record<string, unknown> => !!v && typeof v === 'object',
  );
  for (const obj of candidates) {
    for (const key of ['video', 'url', 'path', 'file']) {
      const v = obj[key];
      if (typeof v === 'string' && /^https?:\/\//i.test(v.trim())) {
        return v.trim();
      }
    }
  }
  return null;
}

export default function CreatePostScreen() {
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams<{ uri?: string; isVideo?: string }>();
  const uri = typeof params.uri === 'string' ? params.uri : '';
  const isVideo = params.isVideo !== '0';
  const token = useAuthStore((s) => s.token);
  const draftLocation = usePostDraftStore((s) => s.location);

  const [info, setInfo] = useState('');
  const [tagQuery, setTagQuery] = useState('');
  const [allTags, setAllTags] = useState<string[]>([]);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [expiry, setExpiry] = useState(() => new Date());
  const [showCalendar, setShowCalendar] = useState(false);
  const [city, setCity] = useState('');
  const [stateName, setStateName] = useState('');
  const [country, setCountry] = useState('');
  const [lat, setLat] = useState(0);
  const [lng, setLng] = useState(0);
  const [locLoading, setLocLoading] = useState(true);
  const [posting, setPosting] = useState(false);
  const [mediaReady, setMediaReady] = useState(false);

  const player = useVideoPlayer(isVideo && uri ? uri : null, (p) => {
    p.loop = true;
    p.muted = true;
  });

  useEffect(() => {
    const t = setTimeout(() => setMediaReady(true), 400);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    if (!isVideo || !uri) return;
    try {
      player.play();
    } catch {
      // ignore
    }
  }, [isVideo, uri, player]);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      if (!token) return;
      try {
        const raw = await getTags(token);
        if (!cancelled) {
          const list = parseTagList(raw);
          setAllTags(list);
          if (list.length) setSelectedTags([list[0]!]);
        }
      } catch {
        // ignore
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [token]);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      setLocLoading(true);
      try {
        const perm = await Location.requestForegroundPermissionsAsync();
        if (!perm.granted) {
          if (!cancelled) setLocLoading(false);
          return;
        }
        const pos = await Location.getCurrentPositionAsync({
          accuracy: Location.Accuracy.Balanced,
        });
        if (cancelled) return;
        // Don't overwrite if user already picked on map
        if (usePostDraftStore.getState().location) {
          if (!cancelled) setLocLoading(false);
          return;
        }
        setLat(pos.coords.latitude);
        setLng(pos.coords.longitude);
        const places = await Location.reverseGeocodeAsync({
          latitude: pos.coords.latitude,
          longitude: pos.coords.longitude,
        });
        const p = places[0];
        if (p) {
          setCity(p.city || p.subregion || p.district || '');
          setStateName(p.region || '');
          setCountry(p.country || '');
        }
      } catch {
        // ignore
      } finally {
        if (!cancelled) setLocLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  useFocusEffect(
    useCallback(() => {
      const loc = usePostDraftStore.getState().location;
      if (!loc) return;
      setLat(loc.lat);
      setLng(loc.lng);
      setCity(loc.city);
      setStateName(loc.state);
      setCountry(loc.country);
      setLocLoading(false);
    }, [draftLocation]),
  );

  const locationLabel = useMemo(() => {
    if (draftLocation?.label) return draftLocation.label;
    const parts = [city, stateName, country].filter(Boolean);
    return parts.length ? parts.join(', ') : 'Tap to pick on map';
  }, [draftLocation, city, stateName, country]);

  function openMap() {
    router.push({
      pathname: '/chat/pick-location',
      params: {
        lat: String(lat || 0),
        lng: String(lng || 0),
      },
    });
  }

  function onExpiryChange(_event: DateTimePickerEvent, date?: Date) {
    if (Platform.OS === 'android') setShowCalendar(false);
    if (!date) return;
    const max = new Date();
    max.setDate(max.getDate() + 90);
    const min = new Date();
    min.setHours(0, 0, 0, 0);
    let next = date;
    if (next < min) next = min;
    if (next > max) next = max;
    setExpiry(next);
  }

  function toggleTag(tag: string) {
    setSelectedTags((prev) =>
      prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag],
    );
  }

  async function onAddTag() {
    const raw = tagQuery.trim();
    if (!raw || !token) return;
    const name = raw.startsWith('#') ? raw : `#${raw}`;
    const capitalized =
      name.charAt(0) +
      name
        .slice(1)
        .split(' ')
        .map((w) => (w ? w[0]!.toUpperCase() + w.slice(1) : w))
        .join(' ');
    if (!allTags.includes(capitalized)) {
      try {
        await createTag(token, capitalized);
        setAllTags((prev) => [...prev, capitalized]);
      } catch {
        setAllTags((prev) => [...prev, capitalized]);
      }
    }
    setSelectedTags((prev) =>
      prev.includes(capitalized) ? prev : [...prev, capitalized],
    );
    setTagQuery('');
  }

  async function onPost() {
    if (!token || !uri) return;
    if (!info.trim()) {
      Alert.alert('Message', 'Please Enter the Info');
      return;
    }
    setPosting(true);
    try {
      const draftEdits = usePostDraftStore.getState().mediaEdits;
      const infoForApi =
        isVideo && draftEdits
          ? appendMediaEditsToInfo(info.trim(), draftEdits)
          : info.trim();

      const result = await createPost(token, {
        title: 'Test',
        info: infoForApi,
        lat,
        lng,
        city,
        state: stateName,
        country,
        tags: selectedTags,
        expiryDate: expiry.toISOString(),
        videoUri: uri,
      });

      // Cache overlays against remote video URL so feed can draw them.
      if (isVideo && draftEdits) {
        useMediaOverlayStore.getState().remember(uri, draftEdits);
        const remote = extractPostedVideoUrl(result);
        if (remote) {
          useMediaOverlayStore.getState().remember(remote, draftEdits);
        }
      }

      usePostDraftStore.getState().clear();
      useProfileStore.getState().clear();
      notify('Your post was uploaded', {
        title: 'Successful upload',
        kind: 'success',
        route: { type: 'home' },
        inbox: true,
      });
      void useFeedStore.getState().loadCategory(token, 'Trending');
      router.replace('/chat/post-success');
    } catch (e) {
      Alert.alert(
        'Message',
        e instanceof Error
          ? e.message
          : 'Something Went Wrong. Try Checking Your Internet Connect',
      );
    } finally {
      setPosting(false);
    }
  }

  function onBackHome() {
    usePostDraftStore.getState().clear();
    if (router.canDismiss()) router.dismissAll();
    router.replace('/(tabs)');
  }

  const maxExpiry = useMemo(() => {
    const d = new Date();
    d.setDate(d.getDate() + 90);
    return d;
  }, []);

  return (
    <View style={styles.root}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={{ paddingBottom: 120 }}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.mediaBox}>
          {!mediaReady ? (
            <ActivityIndicator color={Brand.primary} style={{ marginTop: 160 }} />
          ) : isVideo && uri ? (
            <VideoView
              style={styles.media}
              player={player}
              contentFit="contain"
              nativeControls={false}
            />
          ) : uri ? (
            <Image source={{ uri }} style={styles.media} resizeMode="contain" />
          ) : null}
        </View>

        <View style={styles.form}>
          <Text style={styles.section}>Add Info</Text>
          <TextField
            label="Write a Brief Caption & Description"
            value={info}
            onChangeText={setInfo}
            multiline
            style={{ minHeight: 90, textAlignVertical: 'top' }}
          />

          <Pressable style={styles.locHeader} onPress={openMap}>
            <Text style={styles.section}>Add Location</Text>
            {locLoading ? (
              <ActivityIndicator color={Brand.primary} />
            ) : (
              <MaterialIcons name="arrow-forward-ios" size={16} color={Brand.textPrimary} />
            )}
          </Pressable>
          <Pressable style={styles.locBox} onPress={openMap}>
            <Text style={styles.locText}>{locationLabel}</Text>
          </Pressable>

          <Text style={[styles.section, { marginTop: 20 }]}>Add Tags</Text>
          <TextField
            label="Search"
            value={tagQuery}
            onChangeText={setTagQuery}
            prefixIcon={require('../../assets/images/ic_search.png')}
            prefixTint={Brand.iconColor}
          />
          {tagQuery.trim() ? (
            <PrimaryButton
              label="add Tag"
              onPress={() => void onAddTag()}
              style={{ marginBottom: 16 }}
            />
          ) : null}
          <View style={styles.tagsWrap}>
            {allTags.map((tag) => {
              const selected = selectedTags.includes(tag);
              return (
                <Pressable
                  key={tag}
                  onPress={() => toggleTag(tag)}
                  style={[styles.tagChip, selected && styles.tagChipOn]}
                >
                  <Text style={[styles.tagText, selected && styles.tagTextOn]}>{tag}</Text>
                </Pressable>
              );
            })}
          </View>

          <Text style={[styles.section, { marginTop: 20 }]}>Add Expiry Date</Text>
          <Pressable style={styles.expiryRow} onPress={() => setShowCalendar(true)}>
            <MaterialIcons name="calendar-month" size={22} color={Brand.textPrimary} />
            <Text style={styles.expiryText}>{formatYmd(expiry)}</Text>
            <MaterialIcons name="arrow-forward-ios" size={16} color={Brand.textPrimary} />
          </Pressable>
        </View>
      </ScrollView>

      <View style={[styles.footer, { paddingBottom: Math.max(insets.bottom, 16) }]}>
        <PrimaryButton label="Post" loading={posting} onPress={() => void onPost()} />
      </View>

      <View style={[styles.topBar, { paddingTop: insets.top + 12 }]} pointerEvents="box-none">
        <Pressable onPress={onBackHome} style={styles.backBtn} hitSlop={10}>
          <MaterialIcons name="arrow-back-ios-new" size={18} color={Brand.white} />
        </Pressable>
        <Text style={styles.title}>Add a new Post</Text>
        <View style={{ width: 40 }} />
      </View>

      {Platform.OS === 'ios' ? (
        <Modal visible={showCalendar} transparent animationType="slide">
          <View style={styles.calBackdrop}>
            <Pressable style={StyleSheet.absoluteFill} onPress={() => setShowCalendar(false)} />
            <View style={styles.calSheet}>
              <View style={styles.calHeader}>
                <Text style={styles.calTitle}>Select expiry</Text>
                <Pressable onPress={() => setShowCalendar(false)} hitSlop={10}>
                  <Text style={styles.calDone}>Done</Text>
                </Pressable>
              </View>
              <View style={styles.calPickerWrap}>
                <DateTimePicker
                  value={expiry}
                  mode="date"
                  display="inline"
                  themeVariant="light"
                  textColor={Brand.textPrimary}
                  accentColor={Brand.primary}
                  minimumDate={new Date()}
                  maximumDate={maxExpiry}
                  onChange={onExpiryChange}
                  style={styles.calPicker}
                />
              </View>
            </View>
          </View>
        </Modal>
      ) : showCalendar ? (
        <DateTimePicker
          value={expiry}
          mode="date"
          display="default"
          themeVariant="light"
          accentColor={Brand.primary}
          minimumDate={new Date()}
          maximumDate={maxExpiry}
          onChange={onExpiryChange}
        />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  scroll: { flex: 1, backgroundColor: Brand.white },
  mediaBox: {
    height: 400,
    backgroundColor: '#000',
    marginTop: Platform.OS === 'ios' ? 70 : 60,
  },
  media: { width: '100%', height: '100%' },
  form: { paddingHorizontal: 10, paddingTop: 12 },
  section: {
    fontSize: 16,
    fontWeight: '600',
    color: Brand.textPrimary,
    marginBottom: 12,
  },
  locHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  locBox: {
    borderWidth: 0.5,
    borderColor: Brand.txtGrey,
    borderRadius: 10,
    paddingHorizontal: 10,
    paddingVertical: 10,
  },
  locText: { fontSize: 15, color: Brand.textPrimary },
  tagsWrap: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  tagChip: {
    borderWidth: 1,
    borderColor: Brand.border,
    borderRadius: 100,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  tagChipOn: {
    backgroundColor: Brand.primaryBottom,
    borderColor: Brand.primaryBottom,
  },
  tagText: { fontSize: 13, color: Brand.textPrimary },
  tagTextOn: { color: Brand.white, fontWeight: '600' },
  expiryRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingVertical: 6,
  },
  expiryText: { fontSize: 16, color: Brand.txtGrey, flex: 1 },
  footer: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: Brand.white,
    paddingHorizontal: 30,
    paddingTop: 16,
  },
  topBar: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    zIndex: 5,
  },
  backBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.5)',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0,0,0,0.25)',
  },
  title: {
    flex: 1,
    textAlign: 'center',
    color: Brand.white,
    fontSize: 17,
    fontWeight: '600',
  },
  calBackdrop: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.45)',
  },
  calSheet: {
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    paddingBottom: 28,
    overflow: 'hidden',
  },
  calHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: Brand.borderLight,
    backgroundColor: '#FFFFFF',
  },
  calTitle: { fontSize: 16, fontWeight: '600', color: Brand.textPrimary },
  calDone: { fontSize: 16, fontWeight: '700', color: Brand.primary },
  calPickerWrap: {
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingTop: 4,
  },
  calPicker: {
    alignSelf: 'stretch',
    backgroundColor: '#FFFFFF',
    height: 360,
  },
});
