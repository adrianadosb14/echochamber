import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {

  static const String address = '127.0.0.1';
  static const String port = '3000';

  static Future<http.Response> sendPostReq({required String operation, required Object body}) async {
    http.Response res = await http.post(
      Uri.parse('http://$address:$port/api/$operation'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(body)
    );

    return res;
  }

}