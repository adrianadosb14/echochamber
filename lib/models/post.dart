import 'dart:convert';

import 'package:echo_chamber/util/http_service.dart';
import 'package:http/http.dart' as http;

Post postFromJson(String str) => Post.fromJson(json.decode(str));

class Post {
  String? postId;
  String? userId;
  String? username;
  String? eventId;
  String? content;
  DateTime? creationDate;


  Post({
    this.postId,
    this.userId,
    this.username,
    this.eventId,
    this.content,
    this.creationDate,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
      postId: json["o_post_id"],
      userId: json["o_user_id"],
      username: json["o_username"],
      eventId: json["o_event_id"],
      content: json["o_content"],
      creationDate: DateTime.parse(json["o_creation_date"]),
  );

  static Future<bool> create(
      { required String userId,
        required String eventId,
        required String content,
      }) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'create_post',
        body: {
          "i_user_id" : userId,
          "i_event_id" : eventId,
          "i_content" : content,
        });
    return (json.decode(jsonRes.body)[0]['o_post_id'] != null);
  }

  static Future<List<Post>> getPosts(String eventId) async {
    List<Post> list = [];
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'get_posts',
        body: {
          "i_event_id" : eventId,
        });


    for (int i = 0; i < jsonDecode(jsonRes.body).length; i++) {
      list.add(Post.fromJson(jsonDecode(jsonRes.body)[i]));
    }

    return list;
  }

}