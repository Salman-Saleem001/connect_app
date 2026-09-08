import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';

import { STORAGE_KEYS } from '@/constants/api';
import * as authApi from '@/services/api/auth';
import { ApiError } from '@/services/api/client';
import type { RegisterPayload, User, UserModel } from '@/types/user';

type AuthState = {
  user: User | null;
  token: string | null;
  isHydrated: boolean;
  isLoading: boolean;
  error: string | null;
  hydrate: () => Promise<void>;
  login: (email: string, password: string, fcmToken?: string) => Promise<boolean>;
  register: (payload: RegisterPayload) => Promise<boolean>;
  socialLogin: (provider: string, accessToken: string, fcmToken?: string) => Promise<boolean>;
  logout: () => Promise<void>;
  patchUser: (partial: Partial<User>) => Promise<void>;
  deleteAccount: () => Promise<boolean>;
  clearError: () => void;
};

async function persistSession(session: UserModel) {
  await AsyncStorage.setItem(STORAGE_KEYS.userJson, JSON.stringify(session));
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: null,
  isHydrated: false,
  isLoading: false,
  error: null,

  clearError: () => set({ error: null }),

  hydrate: async () => {
    try {
      const raw = await AsyncStorage.getItem(STORAGE_KEYS.userJson);
      if (raw) {
        const session = JSON.parse(raw) as UserModel;
        set({
          user: session.user ?? null,
          token: session.token ?? null,
          isHydrated: true,
        });
        return;
      }
    } catch {
      // ignore corrupt storage
    }
    set({ user: null, token: null, isHydrated: true });
  },

  login: async (email, password, fcmToken = '') => {
    set({ isLoading: true, error: null });
    try {
      const session = await authApi.login({
        email: email.trim(),
        password,
        fcm_token: fcmToken,
      });

      if (!session?.token) {
        set({
          isLoading: false,
          error: 'Something went wrong. Please try again',
        });
        return false;
      }

      await persistSession(session);
      set({
        user: session.user ?? null,
        token: session.token,
        isLoading: false,
      });
      return true;
    } catch (e) {
      const message =
        e instanceof ApiError
          ? e.message
          : 'Email or password are incorrect. Please try again';
      set({ isLoading: false, error: message });
      return false;
    }
  },

  register: async (payload) => {
    set({ isLoading: true, error: null });
    try {
      await authApi.register(payload);
      set({ isLoading: false });
      return true;
    } catch (e) {
      const message =
        e instanceof ApiError ? e.message : 'Something went wrong. Please try again';
      set({ isLoading: false, error: message });
      return false;
    }
  },

  socialLogin: async (provider, accessToken, fcmToken = '') => {
    set({ isLoading: true, error: null });
    try {
      const session = await authApi.socialLogin({
        provider,
        access_token: accessToken,
        fcm_token: fcmToken,
      });

      if (!session?.token) {
        set({
          isLoading: false,
          error: 'Something went wrong. Please try again',
        });
        return false;
      }

      await persistSession(session);
      set({
        user: session.user ?? null,
        token: session.token,
        isLoading: false,
      });
      return true;
    } catch (e) {
      const message =
        e instanceof ApiError ? e.message : 'Social login failed. Please try again';
      set({ isLoading: false, error: message });
      return false;
    }
  },

  logout: async () => {
    await AsyncStorage.removeItem(STORAGE_KEYS.userJson);
    set({ user: null, token: null, error: null });
  },

  patchUser: async (partial) => {
    const state = useAuthStore.getState();
    if (!state.user || !state.token) return;
    const nextUser = { ...state.user, ...partial };
    const session: UserModel = { user: nextUser, token: state.token };
    await persistSession(session);
    set({ user: nextUser });
  },

  deleteAccount: async () => {
    const { token } = useAuthStore.getState();
    if (!token) return false;
    try {
      await authApi.deleteProfile(token);
      await AsyncStorage.removeItem(STORAGE_KEYS.userJson);
      set({ user: null, token: null, error: null });
      return true;
    } catch {
      return false;
    }
  },
}));
