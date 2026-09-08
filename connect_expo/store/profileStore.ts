import { create } from 'zustand';

import {
  deletePost,
  getBlockedUsers,
  getMyPosts,
  unblockUser,
} from '@/services/api/posts';
import type { Post } from '@/types/posts';
import type { User } from '@/types/user';

function asRecord(v: unknown): Record<string, unknown> | null {
  return v && typeof v === 'object' ? (v as Record<string, unknown>) : null;
}

function parseBlockedUsers(raw: unknown): User[] {
  const o = asRecord(raw) ?? {};
  const list = Array.isArray(o.blocked_users)
    ? o.blocked_users
    : Array.isArray(o.blockedUsers)
      ? o.blockedUsers
      : Array.isArray(raw)
        ? raw
        : [];
  return list
    .map((item) => {
      const u = asRecord(item);
      if (!u || u.id == null) return null;
      return {
        id: Number(u.id),
        first_name: u.first_name != null ? String(u.first_name) : undefined,
        last_name: u.last_name != null ? String(u.last_name) : undefined,
        username: u.username != null ? String(u.username) : undefined,
        avatar: u.avatar != null ? String(u.avatar) : null,
        email: u.email != null ? String(u.email) : undefined,
      } as User;
    })
    .filter((u): u is User => !!u);
}

type ProfileState = {
  posts: Post[];
  loadingPosts: boolean;
  postsFetched: boolean;
  blocked: User[];
  loadingBlocked: boolean;
  fetchMyPosts: (token: string) => Promise<void>;
  removePost: (token: string, id: number) => Promise<boolean>;
  fetchBlocked: (token: string) => Promise<void>;
  unblock: (token: string, userId: number) => Promise<boolean>;
  clear: () => void;
};

export const useProfileStore = create<ProfileState>((set, get) => ({
  posts: [],
  loadingPosts: false,
  postsFetched: false,
  blocked: [],
  loadingBlocked: false,

  clear: () =>
    set({
      posts: [],
      loadingPosts: false,
      postsFetched: false,
      blocked: [],
      loadingBlocked: false,
    }),

  fetchMyPosts: async (token) => {
    set({ loadingPosts: true });
    try {
      const data = await getMyPosts(token);
      set({
        posts: Array.isArray(data?.posts) ? data.posts : [],
        postsFetched: true,
        loadingPosts: false,
      });
    } catch {
      set({ postsFetched: true, loadingPosts: false });
    }
  },

  removePost: async (token, id) => {
    try {
      await deletePost(token, id);
      set({ posts: get().posts.filter((p) => p.id !== id) });
      return true;
    } catch {
      return false;
    }
  },

  fetchBlocked: async (token) => {
    set({ loadingBlocked: true, blocked: [] });
    try {
      const raw = await getBlockedUsers(token);
      set({ blocked: parseBlockedUsers(raw), loadingBlocked: false });
    } catch {
      set({ blocked: [], loadingBlocked: false });
    }
  },

  unblock: async (token, userId) => {
    try {
      await unblockUser(token, userId);
      set({ blocked: get().blocked.filter((u) => u.id !== userId) });
      return true;
    } catch {
      return false;
    }
  },
}));
