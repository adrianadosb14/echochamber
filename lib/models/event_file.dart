import 'dart:convert';

import 'package:echo_chamber/util/http_service.dart';
import 'package:http/http.dart' as http;

EventFile postFromJson(String str) => EventFile.fromJson(json.decode(str));

class EventFile {
  String? fileId;
  String? userId;
  String? username;
  String? filename;
  String? eventFileId;
  String? eventId;
  String? content;

  EventFile({
    this.fileId,
    this.userId,
    this.username,
    this.filename,
    this.eventFileId,
    this.eventId
  });

  factory EventFile.fromJson(Map<String, dynamic> json) => EventFile(
      fileId: json["o_file_id"],
      userId: json["o_user_id"],
      username: json["o_username"],
      filename: json["o_filename"],
      eventFileId: json["o_event_file_id"],
      eventId: json["o_event_id"]
  );

  static Future<bool> create(
      {
        required String userId,
        required String eventId,
        required String filename,
        required String content,
      }) async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'create_event_file',
        body: {
          "i_event_id" : eventId,
          "i_user_id" : userId,
          "i_filename" : filename,
          "i_content" : content
        });
    return (json.decode(jsonRes.body)[0]['o_event_file_id'] != null);
  }

  Future<bool> remove() async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'remove_event_file',
        body: {
          "i_event_file_id" : eventFileId,
          "i_user_id" : userId,
        });
    return (json.decode(jsonRes.body)[0]['o_event_file_id'] != null);
  }

  Future<bool> getContent() async {
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'read_file',
        body: {
          "i_file_id" : fileId,
        });

    content = json.decode(jsonRes.body)['o_content'];
    return (content != null);
  }


  static Future<List<EventFile>> getEventFiles(String eventId) async {
    List<EventFile> list = [];
    http.Response jsonRes = await HttpService.sendPostReq(
        operation: 'get_event_files',
        body: {
          "i_event_id" : eventId
        });


    for (int i = 0; i < jsonDecode(jsonRes.body).length; i++) {
      list.add(EventFile.fromJson(jsonDecode(jsonRes.body)[i]));
    }

    return list;
  }

}