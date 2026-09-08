/** Google Maps key — same as Flutter `MapKey.mapKey`. */
export const GOOGLE_MAPS_API_KEY = 'AIzaSyC9FPLBwpCIQIRVERrlmHv94qv4u9zmILw';

/** Static map image for chat location bubbles. */
export function staticMapPreviewUrl(
  lat: number,
  lng: number,
  width = 420,
  height = 180,
) {
  return (
    `https://maps.googleapis.com/maps/api/staticmap` +
    `?center=${lat},${lng}` +
    `&zoom=15` +
    `&size=${width}x${height}` +
    `&scale=2` +
    `&maptype=roadmap` +
    `&markers=color:0xEF274D%7C${lat},${lng}` +
    `&key=${GOOGLE_MAPS_API_KEY}`
  );
}

export async function reverseGeocodeGoogle(
  latitude: number,
  longitude: number,
): Promise<string | null> {
  const detailed = await reverseGeocodeGoogleDetailed(latitude, longitude);
  return detailed?.label ?? null;
}

export type GeocodeParts = {
  label: string;
  city: string;
  state: string;
  country: string;
  lat?: number;
  lng?: number;
};

export type PlacePrediction = {
  placeId: string;
  description: string;
};

/** Google Places Autocomplete — Flutter `GoogleMapFunctions.predict`. */
export async function autocompletePlaces(
  input: string,
): Promise<PlacePrediction[]> {
  const q = input.trim();
  if (q.length < 2) return [];
  try {
    const url =
      `https://maps.googleapis.com/maps/api/place/autocomplete/json` +
      `?input=${encodeURIComponent(q)}` +
      `&key=${GOOGLE_MAPS_API_KEY}`;
    const res = await fetch(url);
    const json = (await res.json()) as {
      status?: string;
      predictions?: { place_id?: string; description?: string }[];
    };
    if (json.status !== 'OK' && json.status !== 'ZERO_RESULTS') return [];
    return (json.predictions ?? [])
      .map((p) => ({
        placeId: p.place_id ?? '',
        description: p.description ?? '',
      }))
      .filter((p) => p.placeId && p.description);
  } catch {
    return [];
  }
}

/** Resolve a place_id or free-text address to lat/lng + city/state/country. */
export async function geocodePlaceQuery(
  query: string,
  placeId?: string,
): Promise<GeocodeParts | null> {
  try {
    if (placeId) {
      const url =
        `https://maps.googleapis.com/maps/api/place/details/json` +
        `?place_id=${encodeURIComponent(placeId)}` +
        `&fields=geometry,formatted_address,address_component` +
        `&key=${GOOGLE_MAPS_API_KEY}`;
      const res = await fetch(url);
      const json = (await res.json()) as {
        status?: string;
        result?: {
          formatted_address?: string;
          geometry?: { location?: { lat?: number; lng?: number } };
          address_components?: {
            long_name?: string;
            types?: string[];
          }[];
        };
      };
      if (json.status === 'OK' && json.result) {
        return partsFromGoogleComponents(
          json.result.formatted_address ?? query,
          json.result.address_components ?? [],
          json.result.geometry?.location?.lat,
          json.result.geometry?.location?.lng,
        );
      }
    }

    const url =
      `https://maps.googleapis.com/maps/api/geocode/json` +
      `?address=${encodeURIComponent(query)}` +
      `&key=${GOOGLE_MAPS_API_KEY}`;
    const res = await fetch(url);
    const json = (await res.json()) as {
      status?: string;
      results?: {
        formatted_address?: string;
        geometry?: { location?: { lat?: number; lng?: number } };
        address_components?: {
          long_name?: string;
          types?: string[];
        }[];
      }[];
    };
    if (json.status !== 'OK' || !json.results?.[0]) return null;
    const result = json.results[0];
    return partsFromGoogleComponents(
      result.formatted_address ?? query,
      result.address_components ?? [],
      result.geometry?.location?.lat,
      result.geometry?.location?.lng,
    );
  } catch {
    return null;
  }
}

function partsFromGoogleComponents(
  label: string,
  comps: { long_name?: string; types?: string[] }[],
  lat?: number,
  lng?: number,
): GeocodeParts {
  const find = (...types: string[]) =>
    comps.find((c) => types.some((t) => c.types?.includes(t)))?.long_name ?? '';
  return {
    label,
    city: find(
      'locality',
      'postal_town',
      'sublocality',
      'administrative_area_level_2',
    ),
    state: find('administrative_area_level_1'),
    country: find('country'),
    lat,
    lng,
  };
}

/** Parse Google Geocode result into city / state / country like Flutter map screen. */
export async function reverseGeocodeGoogleDetailed(
  latitude: number,
  longitude: number,
): Promise<GeocodeParts | null> {
  try {
    const url =
      `https://maps.googleapis.com/maps/api/geocode/json` +
      `?latlng=${latitude},${longitude}` +
      `&key=${GOOGLE_MAPS_API_KEY}`;
    const res = await fetch(url);
    const json = (await res.json()) as {
      status?: string;
      results?: {
        formatted_address?: string;
        address_components?: {
          long_name?: string;
          short_name?: string;
          types?: string[];
        }[];
      }[];
    };
    if (json.status !== 'OK' || !json.results?.[0]) return null;
    const result = json.results[0];
    return {
      ...partsFromGoogleComponents(
        result.formatted_address ?? '',
        result.address_components ?? [],
      ),
      lat: latitude,
      lng: longitude,
    };
  } catch {
    return null;
  }
}
