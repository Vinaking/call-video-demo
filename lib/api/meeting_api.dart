import 'dart:convert';

import 'package:call_video_demo/utils/user.utils.dart';
import 'package:http/http.dart' as http;

String MEETING_APP_URL = "https://call-video-server.onrender.com/api/meeting";
// String MEETING_APP_URL = "http://10.5.11.86:3002/api/meeting";
var client = http.Client();

Map<String, String> requestHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization'
};

Future<http.Response?> startMeeting() async {
  var userId = await loadUserId();

  var response = await client.post(
    Uri.parse('$MEETING_APP_URL/start'),
    headers: requestHeaders,
    body: jsonEncode({
      'hostId': userId,
      'hostName': ''
    })
  );

  if(response.statusCode == 200) {
    return response;
  }

  return null;
}

Future<http.Response?> joinMeeting(String meetingId) async {
  var response = await http.get(Uri.parse("$MEETING_APP_URL/join?meetingId=$meetingId"));

  if(response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }

  throw UnsupportedError("Not a valid Meeting");
}
