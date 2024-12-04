import 'dart:convert';

import 'package:echo_chamber/util/http_service.dart';
import 'package:http/http.dart' as http;

Tag postFromJson(String str) => Tag.fromJson(json.decode(str));

class Tag {
  String? tagId;
  String? name;
  String? color;
  String? eventId;

  Tag({
    this.tagId,
    this.name,
    this.color,
    this.eventId
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    tagId: json["o_tag_id"],
    name: json["o_name"],
    color: json["o_color"],
    eventId: json["o_event_id"],
  );

  static Future<bool> create(
      {
        required String name,
        required String color
      }) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'create_tag',
        body: {
          "i_name" : name,
          "i_color" : color
        });
    return (json.decode(jsonRes.body)[0]['o_tag_id'] != null);
  }

  Future<bool> addToEvent(
      {
        required String eventId
      }) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'create_event_tag',
        body: {
          "i_event_id" : eventId,
          "i_tag_id" : tagId
        });
    return (json.decode(jsonRes.body)[0]['o_event_tag_id'] != null);
  }

  static Future<List<Tag>> getEventTags(String eventId) async {
    List<Tag> list = [];
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'get_event_tags',
        body: {
          "i_event_id" : eventId
        });


    for (int i = 0; i < jsonDecode(jsonRes.body).length; i++) {
      list.add(Tag.fromJson(jsonDecode(jsonRes.body)[i]));
    }

    return list;
  }

  static Future<List<Tag>> getAllTags() async {
    List<Tag> list = [];
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'get_all_tags',
        body: {
        });


    for (int i = 0; i < jsonDecode(jsonRes.body).length; i++) {
      list.add(Tag.fromJson(jsonDecode(jsonRes.body)[i]));
    }

    return list;
  }

}