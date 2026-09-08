/** Mirrors Flutter `StoriesModel` / `MyStories`. */
export type StoryUser = {
  id?: number;
  name?: string;
  first_name?: string;
  last_name?: string;
  username?: string;
  avatar?: string | null;
  bio?: string | null;
};

export type StoryItem = {
  id: number;
  user_id?: number;
  caption?: string | null;
  media?: string | null;
  media_type?: string | null;
  thumbnail?: string | null;
  expires_at?: string | null;
  total_views?: number;
  created_at?: string | null;
  updated_at?: string | null;
  views_count?: number;
  is_viewed?: boolean;
  user?: StoryUser | null;
};

export type StoriesPayload = {
  my_stories: StoryItem[];
  feed: StoryItem[];
};

function asRecord(v: unknown): Record<string, unknown> | null {
  return v && typeof v === 'object' ? (v as Record<string, unknown>) : null;
}

function parseUser(raw: unknown): StoryUser | null {
  const o = asRecord(raw);
  if (!o) return null;
  return {
    id: typeof o.id === 'number' ? o.id : Number(o.id) || undefined,
    name: o.name != null ? String(o.name) : undefined,
    first_name: o.first_name != null ? String(o.first_name) : undefined,
    last_name: o.last_name != null ? String(o.last_name) : undefined,
    username: o.username != null ? String(o.username) : undefined,
    avatar: o.avatar != null ? String(o.avatar) : null,
    bio: o.bio != null ? String(o.bio) : null,
  };
}

export function parseStoryItem(raw: unknown): StoryItem | null {
  const o = asRecord(raw);
  if (!o || o.id == null) return null;
  const id = Number(o.id);
  if (!Number.isFinite(id)) return null;
  return {
    id,
    user_id: o.user_id != null ? Number(o.user_id) : undefined,
    caption: o.caption != null ? String(o.caption) : null,
    media: o.media != null ? String(o.media) : null,
    media_type: o.media_type != null ? String(o.media_type) : null,
    thumbnail: o.thumbnail != null ? String(o.thumbnail) : null,
    expires_at: o.expires_at != null ? String(o.expires_at) : null,
    total_views: o.total_views != null ? Number(o.total_views) : undefined,
    created_at: o.created_at != null ? String(o.created_at) : null,
    updated_at: o.updated_at != null ? String(o.updated_at) : null,
    views_count: o.views_count != null ? Number(o.views_count) : undefined,
    is_viewed: !!o.is_viewed,
    user: parseUser(o.user),
  };
}

export function parseStoriesPayload(raw: unknown): StoriesPayload {
  let o = asRecord(raw) ?? {};
  // Some responses wrap as { data: { my_stories, feed } }
  if (!Array.isArray(o.my_stories) && !Array.isArray(o.feed)) {
    const nested = asRecord(o.data);
    if (nested) o = nested;
  }
  const mine = Array.isArray(o.my_stories)
    ? o.my_stories
    : Array.isArray(o.myStories)
      ? o.myStories
      : [];
  const feed = Array.isArray(o.feed) ? o.feed : [];
  return {
    my_stories: mine.map(parseStoryItem).filter((s): s is StoryItem => !!s),
    feed: feed.map(parseStoryItem).filter((s): s is StoryItem => !!s),
  };
}

/** Instagram-style: one ring per person, with all of their stories queued. */
export type FeedStoryGroup = {
  key: string;
  userId?: number;
  name: string;
  avatar?: string | null;
  hasUnviewed: boolean;
  stories: StoryItem[];
};

export function groupFeedStories(feed: StoryItem[]): FeedStoryGroup[] {
  const order: string[] = [];
  const map = new Map<string, FeedStoryGroup>();

  for (const item of feed) {
    const userId = item.user?.id ?? item.user_id;
    const key =
      userId != null && Number.isFinite(userId)
        ? `u-${userId}`
        : `s-${item.id}`;
    const existing = map.get(key);
    if (existing) {
      existing.stories.push(item);
      if (!item.is_viewed) existing.hasUnviewed = true;
      continue;
    }
    order.push(key);
    map.set(key, {
      key,
      userId: userId != null ? Number(userId) : undefined,
      name:
        item.user?.first_name ||
        item.user?.username ||
        item.user?.name ||
        'User',
      avatar: item.user?.avatar ?? item.thumbnail ?? null,
      hasUnviewed: !item.is_viewed,
      stories: [item],
    });
  }

  return order.map((k) => map.get(k)!);
}
