// import 'package:flutter/foundation.dart';

class User {
  final String uid;
  final String email;
  final String username;

  User({required this.uid, required this.email, required this.username});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map["uid"] ?? "",
      email: map["email"] ?? "",
      username: map["username"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "username": username,
    };
  }
}
