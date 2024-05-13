import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../ID/backend_identifier.dart';
import '../components/network_utililty.dart';

Future<String> getFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  return token ?? "";
}

Future<void> updateFCMToken() async {
  print("Sending fcm token to backend");

  String token = await getFCMToken();
  int userId = BackendIdentifier.userId;

  String baseurl = dotenv.env["BASE_URL"]?? "";
  String route = 'api/v1/users/updateFcmToken';
  Map<String, dynamic> body = {'user': userId, 'fcmToken': token};

  var response = await makePostRequest(baseurl, route, body);
}

Future<void> notifHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}