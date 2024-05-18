import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../ID/backend_identifier.dart';
import '../components/network_utililty.dart';

import 'notification_handler.dart';

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

class CustomNotificationListener extends StatefulWidget {
  final Widget child;

  CustomNotificationListener({required this.child});

  @override
  _NotificationListenerState createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<CustomNotificationListener> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("Listened to a notification while the app was terminated");
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Listened to a notification while the app was in foreground");
      if (message.notification != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Listened to a notification while the app was in background");
      if (message.notification != null) {
        _handleMessage(message);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationHandler(remoteMessage: message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}