import 'dart:developer';

class StoriesModel {
  StoriesModel({
      this.myStories, 
      this.feed,});

  StoriesModel.fromJson(dynamic json) {
    if (json['my_stories'] != null) {
      myStories = [];
      json['my_stories'].forEach((v) {
        myStories?.add(MyStories.fromJson(v));
      });
    }
    if (json['feed'] != null) {
      log("Feed Not null ${json['feed']}");
      feed = [];
      json['feed'].forEach((v) {
        feed?.add(MyStories.fromJson(v));
      });
    }
  }
  List<MyStories>? myStories;
  List<MyStories>? feed;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (myStories != null) {
      map['my_stories'] = myStories?.map((v) => v.toJson()).toList();
    }
    if (feed != null) {
      map['feed'] = feed?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class MyStories {
  MyStories({
      this.id, 
      this.userId, 
      this.caption, 
      this.media, 
      this.mediaType, 
      this.thumbnail, 
      this.expiresAt, 
      this.totalViews, 
      this.createdAt, 
      this.updatedAt, 
      this.deletedAt, 
      this.viewsCount, 
      this.isViewed, 
      this.user,});

  MyStories.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    caption = json['caption'];
    media = json['media'];
    mediaType = json['media_type'];
    thumbnail = json['thumbnail'];
    expiresAt = json['expires_at'];
    totalViews = json['total_views'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    viewsCount = json['views_count'];
    isViewed = json['is_viewed'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  int? id;
  int? userId;
  String? caption;
  String? media;
  String? mediaType;
  dynamic thumbnail;
  String? expiresAt;
  int? totalViews;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  int? viewsCount;
  bool? isViewed;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['caption'] = caption;
    map['media'] = media;
    map['media_type'] = mediaType;
    map['thumbnail'] = thumbnail;
    map['expires_at'] = expiresAt;
    map['total_views'] = totalViews;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['deleted_at'] = deletedAt;
    map['views_count'] = viewsCount;
    map['is_viewed'] = isViewed;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

}

class User {
  User({
      this.id, 
      this.name, 
      this.email,
      this.blocked,
      this.firstName, 
      this.lastName, 
      this.phone, 
      this.username,
      this.bio, 
      this.avatar,
      this.followed, 
      this.blockedByMe,});

  User.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    blocked = json['blocked'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone'];
    username = json['username'];
    bio = json['bio'];
    avatar = json['avatar'];
    followed = json['followed'];
    blockedByMe = json['blocked_by_me'];
  }
  int? id;
  String? name;
  String? email;
  int? blocked;
  String? firstName;
  String? lastName;
  String? phone;
  String? username;
  String? bio;
  String? avatar;
  String? followed;
  bool? blockedByMe;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['blocked'] = blocked;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['phone'] = phone;
    map['username'] = username;
    map['bio'] = bio;
    map['avatar'] = avatar;
    map['followed'] = followed;
    map['blocked_by_me'] = blockedByMe;
    return map;
  }

}