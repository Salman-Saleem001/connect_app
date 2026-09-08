/**
 * Flutter `GoogleMapScreen` for create-post — search Places, pan map, Done.
 */
import { PrimaryButton } from '@/components/PrimaryButton';
import { Brand } from '@/constants/Colors';
import {
  autocompletePlaces,
  geocodePlaceQuery,
  reverseGeocodeGoogleDetailed,
  type PlacePrediction,
} from '@/constants/maps';
import { usePostDraftStore } from '@/store/postDraftStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import * as Location from 'expo-location';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useCallback, useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Keyboard,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE, type Region } from 'react-native-maps';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const DELTA = 0.02;

export default function PickPostLocationScreen() {
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams<{ lat?: string; lng?: string }>();
  const setLocation = usePostDraftStore((s) => s.setLocation);

  const mapRef = useRef<MapView>(null);
  const geocodeTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const searchTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const skipGeocode = useRef(false);

  const initialLat = Number(params.lat ?? 0) || 30.3753;
  const initialLng = Number(params.lng ?? 0) || 69.3451;

  const [bootLoading, setBootLoading] = useState(true);
  const [addressLoading, setAddressLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [predictions, setPredictions] = useState<PlacePrediction[]>([]);
  const [label, setLabel] = useState('Getting address…');
  const [city, setCity] = useState('');
  const [stateName, setStateName] = useState('');
  const [country, setCountry] = useState('');
  const [coord, setCoord] = useState({ lat: initialLat, lng: initialLng });
  const [region, setRegion] = useState<Region>({
    latitude: initialLat,
    longitude: initialLng,
    latitudeDelta: DELTA,
    longitudeDelta: DELTA,
  });

  const applyParts = useCallback(
    (parts: {
      label: string;
      city: string;
      state: string;
      country: string;
      lat?: number;
      lng?: number;
    }) => {
      setLabel(parts.label);
      setCity(parts.city);
      setStateName(parts.state);
      setCountry(parts.country);
      setSearch(parts.label);
      if (parts.lat != null && parts.lng != null) {
        const next: Region = {
          latitude: parts.lat,
          longitude: parts.lng,
          latitudeDelta: DELTA,
          longitudeDelta: DELTA,
        };
        skipGeocode.current = true;
        setCoord({ lat: parts.lat, lng: parts.lng });
        setRegion(next);
        mapRef.current?.animateToRegion(next, 400);
      }
    },
    [],
  );

  const resolve = useCallback(async (lat: number, lng: number) => {
    setAddressLoading(true);
    setLabel('Getting address…');
    try {
      const google = await reverseGeocodeGoogleDetailed(lat, lng);
      if (google?.label) {
        setLabel(google.label);
        setCity(google.city);
        setStateName(google.state);
        setCountry(google.country);
        setSearch(google.label);
        return;
      }
      const places = await Location.reverseGeocodeAsync({
        latitude: lat,
        longitude: lng,
      });
      const p = places[0];
      if (p) {
        const parts = [p.name, p.street, p.city, p.region, p.country].filter(Boolean);
        const joined = parts.join(', ') || `${lat.toFixed(5)}, ${lng.toFixed(5)}`;
        setLabel(joined);
        setCity(p.city || p.subregion || '');
        setStateName(p.region || '');
        setCountry(p.country || '');
        setSearch(joined);
        return;
      }
      const fallback = `${lat.toFixed(5)}, ${lng.toFixed(5)}`;
      setLabel(fallback);
      setSearch(fallback);
    } catch {
      const fallback = `${lat.toFixed(5)}, ${lng.toFixed(5)}`;
      setLabel(fallback);
      setSearch(fallback);
    } finally {
      setAddressLoading(false);
    }
  }, []);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        const perm = await Location.requestForegroundPermissionsAsync();
        if (perm.granted && (!params.lat || Number(params.lat) === 0)) {
          const pos = await Location.getCurrentPositionAsync({
            accuracy: Location.Accuracy.Balanced,
          });
          if (cancelled) return;
          const next = {
            latitude: pos.coords.latitude,
            longitude: pos.coords.longitude,
            latitudeDelta: DELTA,
            longitudeDelta: DELTA,
          };
          setRegion(next);
          setCoord({ lat: next.latitude, lng: next.longitude });
          await resolve(next.latitude, next.longitude);
        } else {
          await resolve(initialLat, initialLng);
        }
      } catch {
        await resolve(initialLat, initialLng);
      } finally {
        if (!cancelled) setBootLoading(false);
      }
    })();
    return () => {
      cancelled = true;
      if (geocodeTimer.current) clearTimeout(geocodeTimer.current);
      if (searchTimer.current) clearTimeout(searchTimer.current);
    };
  }, []);

  function onRegionChangeComplete(next: Region) {
    setRegion(next);
    setCoord({ lat: next.latitude, lng: next.longitude });
    if (skipGeocode.current) {
      skipGeocode.current = false;
      return;
    }
    if (geocodeTimer.current) clearTimeout(geocodeTimer.current);
    geocodeTimer.current = setTimeout(() => {
      void resolve(next.latitude, next.longitude);
    }, 450);
  }

  function onSearchChange(text: string) {
    setSearch(text);
    if (searchTimer.current) clearTimeout(searchTimer.current);
    if (!text.trim()) {
      setPredictions([]);
      return;
    }
    searchTimer.current = setTimeout(() => {
      void (async () => {
        const list = await autocompletePlaces(text);
        setPredictions(list);
      })();
    }, 300);
  }

  async function onPickPrediction(item: PlacePrediction) {
    Keyboard.dismiss();
    setPredictions([]);
    setAddressLoading(true);
    setSearch(item.description);
    try {
      const parts = await geocodePlaceQuery(item.description, item.placeId);
      if (!parts?.lat || !parts?.lng) {
        Alert.alert('Location', 'Could not find that place. Try another search.');
        return;
      }
      applyParts(parts);
    } catch {
      Alert.alert('Location', 'Could not load that place.');
    } finally {
      setAddressLoading(false);
    }
  }

  function onDone() {
    const hasLabel =
      !!label.trim() &&
      label !== 'Getting address…' &&
      (!!city || !!country || !!search.trim());
    if (!hasLabel) {
      Alert.alert('Message', 'Please select any location');
      return;
    }
    setLocation({
      lat: coord.lat,
      lng: coord.lng,
      city,
      state: stateName,
      country,
      label: label.trim() || search.trim(),
    });
    if (router.canGoBack()) router.back();
  }

  return (
    <View style={styles.root}>
      {bootLoading ? (
        <View style={styles.center}>
          <ActivityIndicator color={Brand.primary} size="large" />
        </View>
      ) : (
        <MapView
          ref={mapRef}
          style={StyleSheet.absoluteFill}
          // Android: Google Maps with configured API key.
          // iOS Expo Go only supports Apple Maps tiles; Places search still uses Google.
          provider={Platform.OS === 'android' ? PROVIDER_GOOGLE : undefined}
          mapType="standard"
          initialRegion={region}
          onRegionChangeComplete={onRegionChangeComplete}
          showsUserLocation
          showsMyLocationButton={Platform.OS === 'android'}
        >
          <Marker
            coordinate={{ latitude: coord.lat, longitude: coord.lng }}
            pinColor={Brand.primary}
          />
        </MapView>
      )}

      <View style={[styles.topBar, { paddingTop: insets.top + 8 }]}>
        <View style={styles.titleRow}>
          <Pressable
            style={styles.back}
            onPress={() => (router.canGoBack() ? router.back() : undefined)}
            hitSlop={10}
          >
            <MaterialIcons name="arrow-back-ios-new" size={18} color={Brand.primaryIconColor} />
          </Pressable>
          <Text style={styles.title}>Add Location</Text>
          <View style={{ width: 40 }} />
        </View>

        <View style={styles.searchWrap}>
          <TextInput
            value={search}
            onChangeText={onSearchChange}
            placeholder="Search for a Location"
            placeholderTextColor={Brand.txtGrey}
            style={styles.searchInput}
            returnKeyType="search"
            autoCorrect={false}
          />
          {search.length > 0 ? (
            <Pressable
              hitSlop={8}
              onPress={() => {
                setSearch('');
                setPredictions([]);
              }}
            >
              <MaterialIcons name="cancel" size={22} color={Brand.primary} />
            </Pressable>
          ) : (
            <MaterialIcons name="search" size={22} color={Brand.iconColor} />
          )}
        </View>

        {predictions.length > 0 ? (
          <View style={styles.predictCard}>
            <FlatList
              keyboardShouldPersistTaps="handled"
              data={predictions}
              keyExtractor={(item) => item.placeId}
              style={{ maxHeight: 200 }}
              renderItem={({ item }) => (
                <Pressable
                  style={styles.predictRow}
                  onPress={() => void onPickPrediction(item)}
                >
                  <Text style={styles.predictText} numberOfLines={2}>
                    {item.description}
                  </Text>
                  <MaterialIcons name="north-east" size={18} color={Brand.txtGrey} />
                </Pressable>
              )}
              ItemSeparatorComponent={() => <View style={styles.predictSep} />}
            />
          </View>
        ) : null}
      </View>

      <View style={[styles.bottom, { paddingBottom: Math.max(insets.bottom, 16) }]}>
        <View style={styles.addressCard}>
          {addressLoading ? (
            <ActivityIndicator color={Brand.primary} />
          ) : (
            <Text style={styles.address}>{label}</Text>
          )}
        </View>
        <PrimaryButton label="done" onPress={onDone} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Brand.white },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  topBar: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    paddingHorizontal: 10,
    zIndex: 4,
    gap: 12,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  back: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Brand.white,
    borderWidth: 1,
    borderColor: Brand.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    flex: 1,
    textAlign: 'center',
    fontSize: 17,
    fontWeight: '600',
    color: Brand.textPrimary,
  },
  searchWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Brand.white,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: Brand.border,
    paddingHorizontal: 10,
    paddingVertical: Platform.OS === 'ios' ? 12 : 4,
    gap: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 15,
    color: Brand.textPrimary,
    paddingVertical: 4,
  },
  predictCard: {
    backgroundColor: Brand.white,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: Brand.borderLight,
    overflow: 'hidden',
  },
  predictRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingHorizontal: 12,
    paddingVertical: 12,
  },
  predictText: { flex: 1, fontSize: 14, color: Brand.textPrimary, lineHeight: 20 },
  predictSep: { height: 1, backgroundColor: Brand.borderLight, marginHorizontal: 16 },
  bottom: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    paddingHorizontal: 12,
    gap: 12,
    zIndex: 2,
  },
  addressCard: {
    backgroundColor: Brand.white,
    borderRadius: 12,
    padding: 14,
    borderWidth: 1,
    borderColor: Brand.borderLight,
    minHeight: 52,
    justifyContent: 'center',
  },
  address: { fontSize: 14, color: Brand.textPrimary, lineHeight: 20 },
});
