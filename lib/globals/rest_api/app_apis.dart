class AppApis{
  static const String baseUrl = 'https://api.connectgiant.com/api';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String socialLogin = '/auth/social-login';
  static const String posts = '/posts';
  static const String report = '$baseUrl$posts/report/';
  static const String userProfile = '/user/me';
  static const String postsTimeLine = '$posts/timeline';
  static const String toggleLikes = '$posts/like-toggle/';
  static const String deleteVideoApi = '$baseUrl$posts/';
  static const String statsOfVideoApi = '$baseUrl$posts/stats/';
  static const String getTags= '$baseUrl/tags';
  static const String getSearchData= '$baseUrl/search';
  static const String getTrendingPosts= '$posts/trending';
  static const String getRecommendedPosts= '$posts/recommended';
  static const String viewedPostApi= '$baseUrl$posts/viewed/';
  static const String ratePostApi= '$baseUrl$posts/rate/';
  static const String followUserApi= '$baseUrl/user/follow/';
  static const String unFollowUserApi= '$baseUrl/user/unfollow/';
  static const String block= '$baseUrl/user/block/';
  static const String unBlock= '$baseUrl/user/unblock/';
  static const String blocked= '$baseUrl/user/blocked/';

  static String get deleteProfileApi => '$baseUrl/user/me';
}