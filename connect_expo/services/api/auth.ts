import { AppApis } from '@/constants/api';
import { ApiError, apiRequest } from '@/services/api/client';
import type {
  LoginPayload,
  RegisterPayload,
  SocialLoginPayload,
  UserModel,
} from '@/types/user';
import { File, UploadType } from 'expo-file-system';

/** Mirrors Flutter `HttpsServices` auth methods. */
export async function login(payload: LoginPayload): Promise<UserModel> {
  return apiRequest<UserModel>(AppApis.login, {
    method: 'POST',
    body: payload,
  });
}

export async function register(payload: RegisterPayload): Promise<unknown> {
  return apiRequest(AppApis.register, {
    method: 'POST',
    body: payload,
  });
}

export async function socialLogin(payload: SocialLoginPayload): Promise<UserModel> {
  return apiRequest<UserModel>(AppApis.socialLogin, {
    method: 'POST',
    body: payload,
  });
}

export async function deleteProfile(token: string): Promise<unknown> {
  return apiRequest(AppApis.deleteProfileApi, {
    method: 'DELETE',
    token,
    absoluteUrl: AppApis.deleteProfileApi,
  });
}

/** Flutter `HttpsServices.updateUser` — multipart POST `/user/me`. */
export async function updateProfile(
  token: string,
  fields: {
    firstName: string;
    lastName: string;
    email: string;
    dob: string;
    avatarUri: string;
  },
): Promise<UserModel> {
  let uri = fields.avatarUri.trim();
  if (uri.startsWith('/') && !uri.startsWith('file://')) uri = `file://${uri}`;
  const file = new File(uri);
  const result = await file.upload(`${AppApis.baseUrl}${AppApis.userProfile}`, {
    httpMethod: 'POST',
    uploadType: UploadType.MULTIPART,
    fieldName: 'avatar',
    mimeType: 'image/jpeg',
    parameters: {
      first_name: fields.firstName,
      last_name: fields.lastName,
      dob: fields.dob,
      email: fields.email,
    },
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${token}`,
    },
  });
  let json: unknown = null;
  if (result.body) {
    try {
      json = JSON.parse(result.body);
    } catch {
      json = result.body;
    }
  }
  if (result.status < 200 || result.status >= 300) {
    const message =
      typeof json === 'object' && json && 'message' in json
        ? String((json as { message: unknown }).message)
        : `Request failed (${result.status})`;
    throw new ApiError(message, result.status, json);
  }
  return json as UserModel;
}
