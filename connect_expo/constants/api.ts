/** Mirrors Flutter `AppApis` — same backend, no server changes. */
export const API_BASE_URL = 'https://api.connectgiant.com/api';

export const AppApis = {
  baseUrl: API_BASE_URL,
  register: '/auth/register',
  login: '/auth/login',
  socialLogin: '/auth/social-login',
  posts: '/posts',
  report: `${API_BASE_URL}/posts/report/`,
  userProfile: '/user/me',
  postsTimeLine: '/posts/timeline',
  toggleLikes: '/posts/like-toggle/',
  deleteVideoApi: `${API_BASE_URL}/posts/`,
  statsOfVideoApi: `${API_BASE_URL}/posts/stats/`,
  getTags: `${API_BASE_URL}/tags`,
  getSearchData: `${API_BASE_URL}/search`,
  getTrendingPosts: '/posts/trending',
  getRecommendedPosts: '/posts/recommended',
  viewedPostApi: `${API_BASE_URL}/posts/viewed/`,
  ratePostApi: `${API_BASE_URL}/posts/rate/`,
  followUserApi: `${API_BASE_URL}/user/follow/`,
  unFollowUserApi: `${API_BASE_URL}/user/unfollow/`,
  block: `${API_BASE_URL}/user/block/`,
  unBlock: `${API_BASE_URL}/user/unblock/`,
  blocked: `${API_BASE_URL}/user/blocked/`,
  stories: `${API_BASE_URL}/stories`,
  deleteProfileApi: `${API_BASE_URL}/user/me`,
} as const;

export const STORAGE_KEYS = {
  userJson: 'userJson',
} as const;

/** Official Connect Giant web pages (site links Flutter never wired). */
export const SupportLinks = {
  help: 'https://connectgiant.com/contact/',
  terms: 'https://connectgiant.com/terms/',
  privacy: 'https://connectgiant.com/privacy-policy/',
  about: 'https://connectgiant.com/',
} as const;
