/** Mirrors Flutter `Post` / `PostModel` JSON. */
export type PostUser = {
  id?: number;
  name?: string | null;
  email?: string;
  first_name?: string;
  last_name?: string;
  username?: string;
  bio?: string;
  avatar?: string | null;
  followed?: string;
};

export type Post = {
  id?: number;
  user_id?: number;
  title?: string;
  video?: string;
  info?: string;
  lat?: string | number;
  lng?: string | number;
  city?: string;
  state?: string;
  country?: string;
  tags?: string[];
  expiry_date?: string;
  total_views?: number | string;
  created_at?: string;
  updated_at?: string;
  likes_count?: number;
  views_count?: number;
  rating?: number | string;
  rated?: boolean;
  isLiked?: boolean;
  user?: PostUser;
  replies?: unknown[];
  thumbnail?: string;
};

export type PostModel = {
  posts?: Post[];
  message?: string;
};

export type FeedCategory = 'My feed' | 'Trending' | 'Recommended';
