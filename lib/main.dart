import 'package:client/screen/Home/Home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'loading.dart';
import 'notification_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Awesome Notifications
  await NotificationController.initializeNotifications();

  // Load login data
  final loginData = await getLoginData();
  final bool isLoggedIn = loginData['isLoggedIn'] as bool;
  final String? userId = loginData['userId'] as String?;
  final String? userName = loginData['userName'] as String?;
  final String? userEmail = loginData['userEmail'] as String?;

  runApp(
    MyApp(
      isLoggedIn: isLoggedIn,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    ),
  );
}

Future<Map<String, dynamic>> getLoginData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool('isLoggedIn') ?? false,
      'userId': prefs.getString('userId'),
      'userName': prefs.getString('userName'),
      'userEmail': prefs.getString('userEmail'),
    };
  } catch (e) {
    return {
      'isLoggedIn': false,
      'userId': null,
      'userName': null,
      'userEmail': null,
    };
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;
  final String? userName;
  final String? userEmail;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.userId,
    this.userName,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;

    if (isLoggedIn && userId != null && userName != null && userEmail != null) {
      initialScreen = HomeScreen(
        userId: userId!,
        userName: userName!,
        userEmail: userEmail!,
      );
    } else {
      initialScreen = const Loading();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}
