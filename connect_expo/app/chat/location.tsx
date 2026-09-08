/**
 * WhatsApp-style share-location screen for chat.
 * Center pin + pan map; address updates after move; Send writes Firestore.
 * Matches Flutter `LocationPickerScreen` fields: latitude, longitude, address.
 */
import { Brand } from '@/constants/Colors';
import { reverseGeocodeGoogle } from '@/constants/maps';
import { sendChatLocation } from '@/services/locationAttach';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import * as Location from 'expo-location';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import MapView, { PROVIDER_GOOGLE, type Region } from 'react-native-maps';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const DELTA = 0.008;

function formatCoords(lat: number, lng: number) {
  return `${lat.toFixed(5)}, ${lng.toFixed(5)}`;
}

function safeBack() {
  if (router.canGoBack()) router.back();
  else router.replace('/(tabs)');
}

export default function ChatLocationPickerScreen() {
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams<{
    chatsId?: string;
    from?: string;
    to?: string;
    videoId?: string;
  }>();

  const mapRef = useRef<MapView>(null);
  const geocodeTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const skipNextGeocode = useRef(false);

  const [bootLoading, setBootLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [addressLoading, setAddressLoading] = useState(false);
  const [address, setAddress] = useState('Getting address…');
  const [region, setRegion] = useState<Region | null>(null);

  const resolveAddress = useCallback(async (lat: number, lng: number) => {
    setAddressLoading(true);
    setAddress('Getting address…');
    try {
      const places = await Location.reverseGeocodeAsync({
        latitude: lat,
        longitude: lng,
      });
      const p = places[0];
      const fromExpo = p
        ? [p.name, p.street, p.city, p.region, p.country].filter(Boolean).join(', ')
        : '';
      if (fromExpo) {
        setAddress(fromExpo);
        return;
      }
      const fromGoogle = await reverseGeocodeGoogle(lat, lng);
      setAddress(fromGoogle || formatCoords(lat, lng));
    } catch {
      const fromGoogle = await reverseGeocodeGoogle(lat, lng);
      setAddress(fromGoogle || formatCoords(lat, lng));
    } finally {
      setAddressLoading(false);
    }
  }, []);

  const scheduleGeocode = useCallback(
    (lat: number, lng: number) => {
      if (geocodeTimer.current) clearTimeout(geocodeTimer.current);
      geocodeTimer.current = setTimeout(() => {
        void resolveAddress(lat, lng);
      }, 450);
    },
    [resolveAddress],
  );

  const moveTo = useCallback(
    async (lat: number, lng: number, animate: boolean) => {
      const next: Region = {
        latitude: lat,
        longitude: lng,
        latitudeDelta: DELTA,
        longitudeDelta: DELTA,
      };
      skipNextGeocode.current = true;
      setRegion(next);
      if (animate) {
        mapRef.current?.animateToRegion(next, 400);
      }
      await resolveAddress(lat, lng);
    },
    [resolveAddress],
  );

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        const perm = await Location.requestForegroundPermissionsAsync();
        if (!perm.granted) {
          Alert.alert('', 'Location permission is required to share your location.');
          safeBack();
          return;
        }
        const pos = await Location.getCurrentPositionAsync({
          accuracy: Location.Accuracy.High,
        });
        if (cancelled) return;
        await moveTo(pos.coords.latitude, pos.coords.longitude, false);
      } catch (e) {
        if (!cancelled) {
          Alert.alert(
            'Location',
            e instanceof Error ? e.message : 'Failed to get current location.',
          );
        }
      } finally {
        if (!cancelled) setBootLoading(false);
      }
    })();
    return () => {
      cancelled = true;
      if (geocodeTimer.current) clearTimeout(geocodeTimer.current);
    };
  }, [moveTo]);

  function onRegionChangeComplete(next: Region) {
    setRegion(next);
    if (skipNextGeocode.current) {
      skipNextGeocode.current = false;
      return;
    }
    scheduleGeocode(next.latitude, next.longitude);
  }

  async function onRecenter() {
    try {
      const pos = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });
      await moveTo(pos.coords.latitude, pos.coords.longitude, true);
    } catch (e) {
      Alert.alert(
        'Location',
        e instanceof Error ? e.message : 'Failed to get current location.',
      );
    }
  }

  async function onSend() {
    if (!region) return;
    const chatsId = params.chatsId;
    const from = params.from;
    const to = params.to;
    const videoId = Number(params.videoId ?? 0);
    if (!chatsId || !from || !to || !Number.isFinite(videoId) || videoId <= 0) {
      Alert.alert('Error', 'Missing chat info.');
      return;
    }

    setSending(true);
    try {
      let finalAddress = address;
      if (addressLoading || finalAddress === 'Getting address…') {
        const places = await Location.reverseGeocodeAsync({
          latitude: region.latitude,
          longitude: region.longitude,
        });
        const p = places[0];
        finalAddress =
          (p
            ? [p.name, p.street, p.city, p.region, p.country].filter(Boolean).join(', ')
            : '') ||
          (await reverseGeocodeGoogle(region.latitude, region.longitude)) ||
          formatCoords(region.latitude, region.longitude);
      }

      await sendChatLocation(
        { chatsId, from, to, videoId },
        {
          latitude: region.latitude,
          longitude: region.longitude,
          address: finalAddress,
        },
      );
      safeBack();
    } catch (e) {
      Alert.alert(
        'Location',
        e instanceof Error ? e.message : 'Failed to send location.',
      );
    } finally {
      setSending(false);
    }
  }

  return (
    <View style={styles.root}>
      <View style={[styles.appBar, { paddingTop: insets.top + 8 }]}>
        <Pressable style={styles.iconBtn} onPress={safeBack} hitSlop={8}>
          <MaterialIcons name="arrow-back-ios" size={22} color={Brand.white} />
        </Pressable>
        <Text style={styles.title}>Share Location</Text>
        <Pressable
          style={styles.iconBtn}
          onPress={() => void onRecenter()}
          hitSlop={8}
          disabled={bootLoading}
        >
          <MaterialIcons name="my-location" size={22} color={Brand.white} />
        </Pressable>
      </View>

      <View style={styles.mapWrap}>
        {bootLoading || !region ? (
          <View style={styles.center}>
            <ActivityIndicator color={Brand.primary} size="large" />
            <Text style={styles.hint}>Getting your location…</Text>
          </View>
        ) : (
          <>
            <MapView
              ref={mapRef}
              style={StyleSheet.absoluteFill}
              provider={Platform.OS === 'android' ? PROVIDER_GOOGLE : undefined}
              initialRegion={region}
              onRegionChangeComplete={onRegionChangeComplete}
              showsUserLocation
              showsMyLocationButton={false}
              showsCompass={false}
              toolbarEnabled={false}
              rotateEnabled={false}
              pitchEnabled={false}
            />
            {/* Fixed center pin (WhatsApp-style) */}
            <View pointerEvents="none" style={styles.centerPinWrap}>
              <MaterialIcons name="location-on" size={44} color={Brand.primary} />
              <View style={styles.pinShadow} />
            </View>
          </>
        )}
      </View>

      {!bootLoading && region ? (
        <View style={[styles.sheet, { paddingBottom: Math.max(insets.bottom, 16) }]}>
          <View style={styles.addrRow}>
            <View style={styles.pinWrap}>
              <MaterialIcons name="location-on" size={24} color={Brand.primary} />
            </View>
            <View style={styles.addrText}>
              <Text style={styles.addrLabel}>Selected location</Text>
              <Text style={styles.addrValue} numberOfLines={2}>
                {address}
              </Text>
            </View>
          </View>
          <Pressable
            style={[styles.sendBtn, sending && styles.sendBtnDisabled]}
            disabled={sending}
            onPress={() => void onSend()}
          >
            {sending ? (
              <ActivityIndicator color={Brand.white} />
            ) : (
              <>
                <MaterialIcons name="send" size={20} color={Brand.white} />
                <Text style={styles.sendLabel}>Send Location</Text>
              </>
            )}
          </Pressable>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.scaffoldDark },
  appBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingBottom: 10,
    backgroundColor: Brand.scaffoldDark,
    zIndex: 2,
  },
  iconBtn: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    flex: 1,
    textAlign: 'center',
    color: Brand.white,
    fontSize: 18,
    fontWeight: '700',
  },
  mapWrap: { flex: 1, backgroundColor: '#1a1a1a' },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
  },
  hint: { color: Brand.white, fontSize: 14 },
  centerPinWrap: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 22,
  },
  pinShadow: {
    width: 10,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'rgba(0,0,0,0.35)',
    marginTop: -4,
  },
  sheet: {
    backgroundColor: '#2a2a2a',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingHorizontal: 20,
    paddingTop: 20,
    gap: 16,
  },
  addrRow: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  pinWrap: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(239,39,77,0.2)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  addrText: { flex: 1 },
  addrLabel: { fontSize: 12, color: '#9E9E9E', marginBottom: 4 },
  addrValue: { fontSize: 14, fontWeight: '600', color: Brand.white },
  sendBtn: {
    height: 50,
    borderRadius: 12,
    backgroundColor: Brand.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  sendBtnDisabled: { opacity: 0.7 },
  sendLabel: { color: Brand.white, fontSize: 16, fontWeight: '600' },
});
