
// class UserModel {
//   late String id;
//   late String fname;
//   late String lname;
//   late String email;
//   late bool approved;
//   late String phone;
//   late String image;
//   late dynamic geo;
//   UserModel({
//     required this.id,
//     required this.fname,
//     required this.lname,
//     required this.email,
//     required this.approved,
//     required this.phone,
//     required this.image,
//     required this.geo,
//   });
//
//   UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
//     try {
//       id = doc.id;
//       var data = doc.data() as Map;
//       fname = data['fname'] ?? '';
//       lname = data['lname'] ?? '';
//       email = data['email'] ?? '';
//       image = data['image'] ?? '';
//       phone = data['phone'] ?? '';
//       geo = doc['geo']['geopoint'] as GeoPoint;
//       approved = data['approved'] ?? false;
//     } catch (e) {}
//   }
//   Map<String, dynamic> toMap() => {
//         "fname": fname,
//         "lname": lname,
//         "email": email,
//         "image": image,
//         "phone": phone,
//         "geo": geo,
//         "createdAt": Timestamp.now(),
//         "approved": false
//       };
//   Map<String, dynamic> toMapSignup() => {
//         "fname": fname,
//         "lname": lname,
//         "email": email,
//         "image": image,
//         "phone": phone,
//         "geo": geo,
//         "createdAt": Timestamp.now(),
//         "approved": false
//       };
// }


class UserModel {
  User? user;
  String? token;

  UserModel({this.user, this.token});

  UserModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? firstName;
  String? lastName;
  String? phone;
  String? username;
  List<String>? preferences;
  String? bio;
  String? avatar;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic dob;
  int? approvedFollowingsCount;
  int? approvedFollowersCount;

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
    this.approvedFollowingsCount,
    this.approvedFollowersCount,
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
    dob: json["dob"],
    approvedFollowingsCount: json["approved_followings_count"],
    approvedFollowersCount: json["approved_followers_count"],
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
    "dob": dob,
    "approved_followings_count": approvedFollowingsCount,
    "approved_followers_count": approvedFollowersCount,
  };
}

