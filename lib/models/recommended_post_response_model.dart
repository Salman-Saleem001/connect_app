/// posts : [{"id":25,"user_id":10,"title":"Test","video":"http://3.123.149.87/storage/videos/8hjorSsdVznF8AgE8X4RMan5MsCKVIrSM4bzqgm4.mp4","info":"test video", ... }]

class RecommendedPostResponseModel {
  RecommendedPostResponseModel({
    List<Posts>? posts,}){
    _posts = posts;
  }

  RecommendedPostResponseModel.fromJson(dynamic json) {
    if (json['posts'] != null) {
      _posts = [];
      json['posts'].forEach((v) {
        _posts?.add(Posts.fromJson(v));
      });
    }
  }
  List<Posts>? _posts;

  RecommendedPostResponseModel copyWith({
    List<Posts>? posts,
  }) => RecommendedPostResponseModel(
    posts: posts ?? _posts,
  );

  List<Posts>? get posts => _posts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_posts != null) {
      map['posts'] = _posts?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Posts {
  Posts({
    int? id,
    int? userId,
    String? title,
    String? video,
    String? info,
    String? lat,
    String? lng,
    String? city,
    String? state,
    String? country,
    List<String>? tags,
    String? expiryDate,
    dynamic totalViews,
    String? createdAt,
    String? updatedAt,
    int? likesCount,
    int? viewsCount,
    User? user,
    List<dynamic>? replies,}){
    _id = id;
    _userId = userId;
    _title = title;
    _video = video;
    _info = info;
    _lat = lat;
    _lng = lng;
    _city = city;
    _state = state;
    _country = country;
    _tags = tags;
    _expiryDate = expiryDate;
    _totalViews = totalViews;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _likesCount = likesCount;
    _viewsCount = viewsCount;
    _user = user;
    _replies = replies;
  }

  Posts.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _title = json['title'];
    _video = json['video'];
    _info = json['info'];
    _lat = json['lat'];
    _lng = json['lng'];
    _city = json['city'];
    _state = json['state'];
    _country = json['country'];
    _tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    _expiryDate = json['expiry_date'];
    _totalViews = json['total_views'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _likesCount = json['likes_count'];
    _viewsCount = json['views_count'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['replies'] != null) {
      _replies = [];
      json['replies'].forEach((v) {
        _replies?.add(v);  // Changed to handle dynamic content
      });
    }
  }

  int? _id;
  int? _userId;
  String? _title;
  String? _video;
  String? _info;
  String? _lat;
  String? _lng;
  String? _city;
  String? _state;
  String? _country;
  List<String>? _tags;
  String? _expiryDate;
  dynamic _totalViews;
  String? _createdAt;
  String? _updatedAt;
  int? _likesCount;
  int? _viewsCount;
  User? _user;
  List<dynamic>? _replies;

  int? get id => _id;
  int? get userId => _userId;
  String? get title => _title;
  String? get video => _video;
  String? get info => _info;
  String? get lat => _lat;
  String? get lng => _lng;
  String? get city => _city;
  String? get state => _state;
  String? get country => _country;
  List<String>? get tags => _tags;
  String? get expiryDate => _expiryDate;
  dynamic get totalViews => _totalViews;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get likesCount => _likesCount;
  int? get viewsCount => _viewsCount;
  User? get user => _user;
  List<dynamic>? get replies => _replies;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['title'] = _title;
    map['video'] = _video;
    map['info'] = _info;
    map['lat'] = _lat;
    map['lng'] = _lng;
    map['city'] = _city;
    map['state'] = _state;
    map['country'] = _country;
    map['tags'] = _tags;
    map['expiry_date'] = _expiryDate;
    map['total_views'] = _totalViews;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['likes_count'] = _likesCount;
    map['views_count'] = _viewsCount;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_replies != null) {
      map['replies'] = _replies;
    }
    return map;
  }
}

class User {
  User({
    int? id,
    dynamic name,
    String? email,
    dynamic emailVerifiedAt,
    String? firstName,
    String? lastName,
    String? phone,
    String? username,
    List<String>? preferences,
    String? bio,
    String? avatar,
    String? createdAt,
    String? updatedAt,
    dynamic dob,}){
    _id = id;
    _name = name;
    _email = email;
    _emailVerifiedAt = emailVerifiedAt;
    _firstName = firstName;
    _lastName = lastName;
    _phone = phone;
    _username = username;
    _preferences = preferences;
    _bio = bio;
    _avatar = avatar;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _dob = dob;
  }

  User.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _email = json['email'];
    _emailVerifiedAt = json['email_verified_at'];
    _firstName = json['first_name'];
    _lastName = json['last_name'];
    _phone = json['phone'];
    _username = json['username'];
    _preferences = json['preferences'] != null ? json['preferences'].cast<String>() : [];
    _bio = json['bio'];
    _avatar = json['avatar'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _dob = json['dob'];
  }

  int? _id;
  dynamic _name;
  String? _email;
  dynamic _emailVerifiedAt;
  String? _firstName;
  String? _lastName;
  String? _phone;
  String? _username;
  List<String>? _preferences;
  String? _bio;
  String? _avatar;
  String? _createdAt;
  String? _updatedAt;
  dynamic _dob;

  int? get id => _id;
  dynamic get name => _name;
  String? get email => _email;
  dynamic get emailVerifiedAt => _emailVerifiedAt;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get phone => _phone;
  String? get username => _username;
  List<String>? get preferences => _preferences;
  String? get bio => _bio;
  String? get avatar => _avatar;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  dynamic get dob => _dob;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['email_verified_at'] = _emailVerifiedAt;
    map['first_name'] = _firstName;
    map['last_name'] = _lastName;
    map['phone'] = _phone;
    map['username'] = _username;
    map['preferences'] = _preferences;
    map['bio'] = _bio;
    map['avatar'] = _avatar;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['dob'] = _dob;
    return map;
  }
}
