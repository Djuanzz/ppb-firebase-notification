import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notification_firebase/firebase_options.dart';
import 'package:notification_firebase/screens/home.screen.dart';
import 'package:notification_firebase/screens/login.screen.dart';
import 'package:notification_firebase/screens/register.screen.dart';
import 'package:notification_firebase/services/notification.service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initializeNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Notification',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: "login",
      routes: {
        "login": (context) => const LoginScreen(),
        "home": (context) => HomeScreen(),
        "register": (context) => const RegisterScreen(),
      },
    );
  }
}
