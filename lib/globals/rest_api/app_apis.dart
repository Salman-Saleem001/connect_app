class AppApis{
  static String baseUrl = 'https://connect-giant.aliraza.xyz/api';
  static String register = '/auth/register';
  static String login = '/auth/login';
  static String posts = '/posts';
  static String userProfile = '/user/me';
  static String postsTimeLine = '$posts/timeline';
  static String toggleLikes = '$posts/like-toggle/';
  static String deleteVideoApi = '$baseUrl$posts/';
  static String statsOfVideoApi = '$baseUrl$posts/stats/';
  static String getTags= '$baseUrl/tags';
  static String getSearchData= '$baseUrl/search';
  static String getTrendingPosts= '$posts/trending';
  static String getRecommendedPosts= '$posts/recommended';
  static String viewedPostApi= '$baseUrl$posts/viewed/';
  static String ratePostApi= '$baseUrl$posts/rate/';
  static String followUserApi= '$baseUrl/user/follow/';
  static String unFollowUserApi= '$baseUrl/user/unfollow/';
}