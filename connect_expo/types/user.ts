/** Mirrors Flutter `User` / `UserModel`. */
export type User = {
  id?: number;
  name?: string;
  email?: string;
  email_verified_at?: string | null;
  first_name?: string;
  last_name?: string;
  phone?: string;
  username?: string;
  preferences?: string[];
  bio?: string;
  avatar?: string | null;
  created_at?: string;
  updated_at?: string;
  dob?: string | null;
  approved_followings_count?: number;
  approved_followers_count?: number;
};

export type UserModel = {
  user?: User;
  token?: string;
};

export type LoginPayload = {
  email: string;
  password: string;
  fcm_token: string;
};

export type RegisterPayload = {
  email: string;
  password: string;
  password_confirmation: string;
  first_name: string;
  last_name: string;
  username: string;
  phone: string;
  preferences: string[];
  bio: string;
};

export type SocialLoginPayload = {
  provider: string;
  access_token: string;
  fcm_token: string;
};
