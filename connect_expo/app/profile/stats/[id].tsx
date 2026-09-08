/**
 * Flutter `StatsMapScreen` — country view markers for a video.
 * Uses approximate country centroids (no Google Geocoding key required).
 */
import { Brand } from '@/constants/Colors';
import { getPostStats } from '@/services/api/posts';
import { useAuthStore } from '@/store/authStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import MapView, { Marker } from 'react-native-maps';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const COUNTRY_COORDS: Record<string, { lat: number; lng: number }> = {
  pakistan: { lat: 30.3753, lng: 69.3451 },
  india: { lat: 20.5937, lng: 78.9629 },
  'united states': { lat: 37.0902, lng: -95.7129 },
  usa: { lat: 37.0902, lng: -95.7129 },
  'united kingdom': { lat: 55.3781, lng: -3.436 },
  uk: { lat: 55.3781, lng: -3.436 },
  canada: { lat: 56.1304, lng: -106.3468 },
  australia: { lat: -25.2744, lng: 133.7751 },
  germany: { lat: 51.1657, lng: 10.4515 },
  france: { lat: 46.2276, lng: 2.2137 },
  uae: { lat: 23.4241, lng: 53.8478 },
  'saudi arabia': { lat: 23.8859, lng: 45.0792 },
  bangladesh: { lat: 23.685, lng: 90.3563 },
  china: { lat: 35.8617, lng: 104.1954 },
  japan: { lat: 36.2048, lng: 138.2529 },
  brazil: { lat: -14.235, lng: -51.9253 },
  nigeria: { lat: 9.082, lng: 8.6753 },
  'south africa': { lat: -30.5595, lng: 22.9375 },
};

type StatRow = { country: string; total_views: number; lat: number; lng: number };

function parseStats(raw: unknown): StatRow[] {
  const o = raw && typeof raw === 'object' ? (raw as Record<string, unknown>) : {};
  const list = Array.isArray(o.stats) ? o.stats : [];
  const out: StatRow[] = [];
  for (const item of list) {
    if (!item || typeof item !== 'object') continue;
    const r = item as Record<string, unknown>;
    const country = r.country != null ? String(r.country) : '';
    const views = Number(r.total_views ?? 0);
    if (!country || !Number.isFinite(views)) continue;
    const key = country.toLowerCase().trim();
    const coords = COUNTRY_COORDS[key] ?? { lat: 20, lng: 0 };
    out.push({ country, total_views: views, lat: coords.lat, lng: coords.lng });
  }
  return out;
}

export default function StatsMapScreen() {
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams<{ id?: string }>();
  const id = Number(params.id ?? 0);
  const token = useAuthStore((s) => s.token);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<StatRow[]>([]);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      if (!token || !id) {
        setLoading(false);
        return;
      }
      try {
        const raw = await getPostStats(token, id);
        if (!cancelled) setStats(parseStats(raw));
      } catch {
        if (!cancelled) setStats([]);
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [token, id]);

  const initial = useMemo(() => {
    const first = stats[0];
    return {
      latitude: first?.lat ?? 30.3753,
      longitude: first?.lng ?? 69.3451,
      latitudeDelta: 40,
      longitudeDelta: 40,
    };
  }, [stats]);

  return (
    <View style={styles.root}>
      {loading ? (
        <View style={styles.center}>
          <ActivityIndicator color={Brand.primary} size="large" />
        </View>
      ) : stats.length === 0 ? (
        <View style={styles.center}>
          <Text style={styles.empty}>No Stats available</Text>
        </View>
      ) : (
        <MapView style={StyleSheet.absoluteFill} initialRegion={initial}>
          {stats.map((s) => (
            <Marker
              key={s.country}
              coordinate={{ latitude: s.lat, longitude: s.lng }}
              title={s.country}
              description={`${s.total_views} Views`}
            />
          ))}
        </MapView>
      )}

      <Pressable
        style={[styles.back, { top: insets.top + 12 }]}
        onPress={() => (router.canGoBack() ? router.back() : router.replace('/(tabs)/profile'))}
        hitSlop={10}
      >
        <MaterialIcons name="arrow-back-ios-new" size={18} color={Brand.primaryIconColor} />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  empty: { fontSize: 18, color: Brand.textPrimary },
  back: {
    position: 'absolute',
    left: 15,
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Brand.white,
    borderWidth: 1,
    borderColor: Brand.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
