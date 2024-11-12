import 'dart:convert';

import 'package:echo_chamber/util/http_service.dart';
import 'package:http/http.dart' as http;

User userFromJson(String str) => User.fromJson(json.decode(str));

class User {
  String? userId;
  String? username;
  String? email;
  String? password;
  String? description;
  String? avatar;
  int? type;
  DateTime? registrationDate;
  DateTime? lastAccess;

  User({
    this.userId,
    this.username,
    this.email,
    this.password,
    this.description,
    this.avatar,
    this.type,
    this.registrationDate,
    this.lastAccess,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["o_user_id"],
    username: json["o_username"],
    email: json["o_email"],
    password: json["o_password"],
    description: json["o_description"],
    avatar: json["o_avatar"],
    type: json["o_type"],
    registrationDate: DateTime.parse(json["o_registration_date"]),
    lastAccess: DateTime.parse(json["o_last_access"])
  );

  static Future<bool> createUser(
      {required String username,
      required String email,
      required String password,
      required String? description,
      required String? avatar,
      required int type}) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'create_user',
        body: {
          "i_username" : username,
          "i_email" : email,
          "i_password" : password,
          "i_description" : description,
          "i_avatar" : avatar,
          "i_type" : type
        });
    return (json.decode(jsonRes.body)[0]['o_user_id'] != null);
  }

  static Future<dynamic> loginUser({required String email, required String password}) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'login_user',
        body: {
          "i_email" : email,
          "i_password" : password
        });
    return json.decode(jsonRes.body);
  }

}