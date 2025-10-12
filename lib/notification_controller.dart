import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;
import '../backend_services/notification_service.dart';

class NotificationController {
  static ReceivedAction? initialAction;
  static ReceivePort? receivePort;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Timer? pollingTimer;
  static final List<String> _fetchedNotificationIds = [];

  /// Initialize Awesome Notifications
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'alerts',
        channelName: 'Alerts',
        channelDescription: 'Notification tests as alerts',
        importance: NotificationImportance.High,
        defaultColor: Colors.deepOrange,
        ledColor: Colors.deepOrange,
        playSound: true,
      ),
    ]);

    initialAction = await AwesomeNotifications().getInitialNotificationAction(
      removeFromActionEvents: false,
    );

    receivePort = ReceivePort('notification_action_port')
      ..listen((dynamic data) {
        _onActionReceivedImplementation(data as ReceivedAction);
      });

    IsolateNameServer.registerPortWithName(
      receivePort!.sendPort,
      'notification_action_port',
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
    );

    _startPolling();
  }

  /// Poll backend every 30 seconds
  static void _startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _fetchAndNotify();
    });
    _fetchAndNotify(); // Initial fetch
  }

  /// Fetch notifications and show only new ones
  static Future<void> _fetchAndNotify() async {
    try {
      final notifications = await NotificationService().fetchAllNotifications();

      for (var notification in notifications) {
        if (!_fetchedNotificationIds.contains(notification.id)) {
          _fetchedNotificationIds.add(notification.id);

          await createNotification(
            title: notification.title,
            body: notification.description,
            bigPicture: notification.imageUrl,
          );
        }
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  /// Handle notification actions
  static Future<void> onActionReceived(ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      await executeBackgroundTask();
    } else {
      SendPort? sendPort = IsolateNameServer.lookupPortByName(
        'notification_action_port',
      );
      sendPort?.send(receivedAction);
    }
  }

  /// Navigate when notification clicked
  static Future<void> _onActionReceivedImplementation(
    ReceivedAction receivedAction,
  ) async {
    navigatorKey.currentState?.pushNamed(
      '/notification-page',
      arguments: receivedAction,
    );
  }

  /// Background task example
  static Future<void> executeBackgroundTask() async {
    await Future.delayed(const Duration(seconds: 3));
    final response = await http.get(
      Uri.parse("https://jsonplaceholder.typicode.com/todos/1"),
    );
    print("Background fetch done: ${response.body}");
  }

  /// Request notification permission
  static Future<void> requestPermission() async {
    bool allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// Create a notification
  static Future<void> createNotification({
    required String title,
    required String body,
    String? bigPicture,
  }) async {
    await requestPermission();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'alerts',
        title: title,
        body: body,
        bigPicture: bigPicture,
        notificationLayout: bigPicture != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        payload: {'title': title, 'body': body, 'bigPicture': bigPicture ?? ''},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'REPLY',
          label: 'Reply',
          requireInputText: true,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
          isDangerousOption: true,
        ),
      ],
    );
  }
}
