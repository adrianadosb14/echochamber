import 'dart:convert';

import 'package:echo_chamber/util/http_service.dart';
import 'package:http/http.dart' as http;

Event eventFromJson(String str) => Event.fromJson(json.decode(str));

class Event {
  String? eventId;
  String? userId;
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  double? latitude;
  double? longitude;

  Event({
    this.eventId,
    this.userId,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.latitude,
    this.longitude,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      eventId: json["o_event_id"],
      userId: json["o_user_id"],
      title: json["o_title"],
      description: json["o_description"],
      startDate: DateTime.parse(json["o_start_date"]),
      endDate: DateTime.parse(json["o_end_date"]),
      latitude: json["o_latitude"],
      longitude: json["o_longitude"]
  );

  static Future<bool> createEvent(
      { required String userId,
        required String title,
        required String description,
        required DateTime? startDate,
        required DateTime? endDate,
        required double latitude,
        required double longitude
      }) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'create_event',
        body: {
          "i_user_id" : userId,
          "i_title" : title,
          "i_description" : description,
          "i_start_date" : startDate?.toIso8601String(),
          "i_end_date" : endDate?.toIso8601String(),
          "i_longitude" : latitude,
          "i_latitude" : longitude
        });
    return (json.decode(jsonRes.body)[0]['o_event_id'] != null);
  }

  static Future<List<Event>> getEvents(
    {String? searchTerm,
      DateTime? startDate,
      DateTime? endDate,
      double? latitude,
      double? longitude,
      double? radius}) async {
    List<Event> list = [];
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'get_events',
        body: {
          "i_search_term" : searchTerm,
          "i_start_date" : startDate?.toIso8601String(),
          "i_end_date" : endDate?.toIso8601String(),
          "i_latitude" : latitude,
          "i_longitude" : longitude,
          "i_radius" : radius
        });


    for (int i = 0; i < jsonDecode(jsonRes.body).length; i++) {
      list.add(Event.fromJson(jsonDecode(jsonRes.body)[i]));
    }

    return list;
  }

}