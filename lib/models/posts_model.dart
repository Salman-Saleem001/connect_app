

class PostModel {
  List<Post>? posts = <Post>[];

  PostModel({this.posts});

  PostModel.fromJson(Map<String, dynamic> json) {
    if (json['posts'] != null) {
      posts = <Post>[];
      json['posts'].forEach((v) {
        posts!.add(Post.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (posts != null) {
      data['posts'] = posts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Post {
  int? id;
  int? userId;
  String? title;
  String? video;
  String? info;
  String? lat;
  String? lng;
  String? city;
  String? state;
  String? country;
  List<String>? tags;
  String? expiryDate;
  dynamic totalViews;
  String? createdAt;
  String? updatedAt;
  int? likesCount;
  int? viewsCount;
  dynamic rating;
  bool? rated;
  bool? isLiked;
  User? user;
  List<dynamic>? replies;
  String? thumbnail;

  Post({
    this.id,
    this.userId,
    this.title,
    this.video,
    this.info,
    this.lat,
    this.lng,
    this.city,
    this.state,
    this.country,
    this.tags,
    this.expiryDate,
    this.totalViews,
    this.createdAt,
    this.updatedAt,
    this.likesCount,
    this.viewsCount,
    this.rating,
    this.rated,
    this.isLiked,
    this.user,
    this.replies,
    this.thumbnail
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"],
    userId: json["user_id"],
    title: json["title"],
    video: json["video"],
    info: json["info"],
    lat: json["lat"],
    lng: json["lng"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
    expiryDate: json["expiry_date"],
    totalViews: json["total_views"],
    createdAt: json["created_at"] ,
    updatedAt: json["updated_at"] ,
    likesCount: json["likes_count"],
    viewsCount: json["views_count"],
    rating: json["rating"],
    rated: json["rated"],
    isLiked: json["isLiked"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    replies: json["replies"] == null ? [] : List<dynamic>.from(json["replies"]!.map((x) => x)),
    thumbnail: json['thumbnail']
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "video": video,
    "info": info,
    "lat": lat,
    "lng": lng,
    "city": city,
    "state": state,
    "country": country,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "expiry_date": expiryDate,
    "total_views": totalViews,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "likes_count": likesCount,
    "views_count": viewsCount,
    "rating": rating,
    "rated": rated,
    "isLiked": isLiked,
    "user": user?.toJson(),
    "replies": replies == null ? [] : List<dynamic>.from(replies!.map((x) => x)),
  };
}

class User {
  int? id;
  dynamic name;
  String? email;
  dynamic emailVerifiedAt;
  String? firstName;
  String? lastName;
  String? phone;
  String? username;
  List<String>? preferences;
  String? bio;
  String? avatar;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? dob;
  String? followed;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.firstName,
    this.lastName,
    this.phone,
    this.username,
    this.preferences,
    this.bio,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.dob,
    this.followed,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    phone: json["phone"],
    username: json["username"],
    preferences: json["preferences"] == null ? [] : List<String>.from(json["preferences"]!.map((x) => x)),
    bio: json["bio"],
    avatar: json["avatar"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    followed: json["followed"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "username": username,
    "preferences": preferences == null ? [] : List<dynamic>.from(preferences!.map((x) => x)),
    "bio": bio,
    "avatar": avatar,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "dob": "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
    "followed": followed,
  };
}

