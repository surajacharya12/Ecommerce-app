import 'package:client/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reactive_theme/reactive_theme.dart';
import 'package:client/Auth/LoginSignup.dart';
import 'package:client/screen/Home/Home.dart';
import 'package:client/screen/Notification/notification.dart';

import 'Auth/loading.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.initializeNotifications();

  // Load loin data
  final loginData = await getLoginData();
  final bool isLoggedIn = loginData['isLoggedIn'] as bool;
  final String? userId = loginData['userId'] as String?;
  final String? userName = loginData['userName'] as String?;
  final String? userEmail = loginData['userEmail'] as String?;
  final bool onboardingCompleted = loginData['onboardingCompleted'] as bool;

  final ThemeMode? savedThemeMode = await ReactiveMode.getSavedThemeMode();

  runApp(
    MyApp(
      isLoggedIn: isLoggedIn,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      savedThemeMode: savedThemeMode,
      onboardingCompleted: onboardingCompleted,
    ),
  );
}

Future<Map<String, dynamic>> getLoginData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? userId = prefs.getString('userId');
    final String? userName = prefs.getString('userName');
    final String? userEmail = prefs.getString('userEmail');
    final bool onboardingCompleted =
        prefs.getBool('onboardingCompleted') ?? false;

    print("main.dart: getLoginData - SharedPreferences check on app start:");
    print("  isLoggedIn: $isLoggedIn");
    print("  userId: $userId");
    print("  userName: $userName");
    print("  userEmail: $userEmail");

    return {
      'isLoggedIn': isLoggedIn,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'onboardingCompleted': onboardingCompleted,
    };
  } catch (e) {
    print("Error reading SharedPreferences in getLoginData (main.dart): $e");
    return {
      'isLoggedIn': false,
      'userId': null,
      'userName': null,
      'userEmail': null,
      'onboardingCompleted': false,
    };
  }
}
// --- END MODIFIED CODE ---

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final ThemeMode? savedThemeMode;
  final bool onboardingCompleted;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.userId,
    this.userName,
    this.userEmail,
    this.savedThemeMode,
    required this.onboardingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Decide start screen based on onboarding + login state
    late final Widget initialScreen;
    if (onboardingCompleted) {
      if (isLoggedIn &&
          userId != null &&
          userName != null &&
          userEmail != null) {
        print(
          "MyApp: Launching directly to Home (onboarding done, user logged in).",
        );
        initialScreen = HomeScreen(
          userId: userId!,
          userName: userName!,
          userEmail: userEmail!,
        );
      } else {
        print(
          "MyApp: Launching to Login/Signup (onboarding done, user not logged in).",
        );
        initialScreen = const LoginSignupScreen();
      }
    } else {
      print("MyApp: Launching to Loading → Onboarding (first run).");
      initialScreen = const Loading();
    }
    return ReactiveThemer(
      savedThemeMode: savedThemeMode,
      builder: (reactiveMode) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        themeMode: reactiveMode,
        title: 'ShopSwift',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: initialScreen,
        routes: {'/notification-page': (_) => const NotificationScreen()},
      ),
    );
  }
}
