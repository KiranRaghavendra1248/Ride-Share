import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:rideshare/screens/welcome_screen.dart';
import 'package:rideshare/theme/theme.dart';


Future<void> getFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("FirebaseMessaging token: $token");
}

Future<void> main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await getFCMToken();
  // FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RideShare',
      theme: lightMode,
      home: const WelcomeScreen(),
    );
  }
}
