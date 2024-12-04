import 'dart:convert';

import 'package:echo_chamber/util/http_service.dart';
import 'package:http/http.dart' as http;

EventLike postFromJson(String str) => EventLike.fromJson(json.decode(str));

class EventLike {
  String? eventLikeId;
  String? userId;
  String? username;
  String? eventId;
  DateTime? creationDate;

  EventLike({
    this.eventLikeId,
    this.userId,
    this.username,
    this.eventId,
    this.creationDate
  });

  factory EventLike.fromJson(Map<String, dynamic> json) => EventLike(
    eventLikeId: json["o_event_like_id"],
    userId: json["o_user_id"],
    username: json["o_username"],
    eventId: json["o_event_id"],
    creationDate: DateTime.parse(json["o_creation_date"])
  );

  static Future<bool> create(
      {
        required String userId,
        required String eventId
      }) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'create_event_like',
        body: {
          "i_user_id" : userId,
          "i_event_id" : eventId
        });
    return (json.decode(jsonRes.body)[0]['o_event_like_id'] != null);
  }

  Future<bool> remove() async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'remove_event_like',
        body: {
          "i_user_id" : userId,
          "i_event_like_id" : eventLikeId
        });
    return (json.decode(jsonRes.body)[0]['o_event_like_id'] != null);
  }


  static Future<List<EventLike>> getEventLikes(String eventId) async {
    List<EventLike> list = [];
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'get_event_likes',
        body: {
          "i_event_id" : eventId
        });


    for (int i = 0; i < jsonDecode(jsonRes.body).length; i++) {
      list.add(EventLike.fromJson(jsonDecode(jsonRes.body)[i]));
    }

    return list;
  }

}