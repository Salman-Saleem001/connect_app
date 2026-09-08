import { API_BASE_URL } from '@/constants/api';

export class ApiError extends Error {
  status: number;
  raw?: unknown;

  constructor(message: string, status: number, raw?: unknown) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.raw = raw;
  }
}

type RequestOptions = {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  token?: string | null;
  body?: unknown;
  /** Absolute URL overrides base + path */
  absoluteUrl?: string;
  formData?: FormData;
};

function buildUrl(pathOrUrl: string, absoluteUrl?: string) {
  if (absoluteUrl) return absoluteUrl;
  if (pathOrUrl.startsWith('http')) return pathOrUrl;
  return `${API_BASE_URL}${pathOrUrl.startsWith('/') ? pathOrUrl : `/${pathOrUrl}`}`;
}

function formatApiErrorMessage(json: unknown, status: number): string {
  if (typeof json === 'string' && json.trim()) return json.trim();
  if (!json || typeof json !== 'object') return `Request failed (${status})`;
  const o = json as Record<string, unknown>;
  if (typeof o.message === 'string' && o.message.trim()) return o.message.trim();
  if (typeof o.error === 'string' && o.error.trim()) return o.error.trim();
  if (o.errors && typeof o.errors === 'object') {
    const parts: string[] = [];
    for (const v of Object.values(o.errors as Record<string, unknown>)) {
      if (Array.isArray(v)) parts.push(...v.map(String));
      else if (v != null) parts.push(String(v));
    }
    if (parts.length) return parts.join('\n');
  }
  if (typeof o.exception === 'string' && o.exception.trim()) return o.exception.trim();
  return `Request failed (${status})`;
}

export async function apiRequest<T = unknown>(
  pathOrUrl: string,
  { method = 'GET', token, body, absoluteUrl, formData }: RequestOptions = {},
): Promise<T> {
  const headers: Record<string, string> = {
    Accept: 'application/json',
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  let requestBody: BodyInit | undefined;

  if (formData) {
    requestBody = formData;
    // Let fetch set multipart boundary
  } else if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    requestBody = JSON.stringify(body);
  }

  const response = await fetch(buildUrl(pathOrUrl, absoluteUrl), {
    method,
    headers,
    body: requestBody,
  });

  const text = await response.text();
  let json: unknown = null;
  if (text) {
    try {
      json = JSON.parse(text);
    } catch {
      json = text;
    }
  }

  if (!response.ok) {
    throw new ApiError(formatApiErrorMessage(json, response.status), response.status, json);
  }

  return json as T;
}
