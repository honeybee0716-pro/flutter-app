import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationProvider {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String token = '';
  final _messageStreamController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageStreamController.stream;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PushNotificationProvider() {
    _init();
  }

  void _init() async {
    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    initializeLocalNotifications();
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      onResume(msg);
    });

    FirebaseMessaging.onMessage.listen((msg) {
      onMessage(msg);
    });

    FirebaseMessaging.onBackgroundMessage((message) => onLaunch(message));
  }

  Future<String> getUserToken(String user) async {
    token = await messaging.getToken() ?? '';
    return token;
  }


  Future<void> initializeLocalNotifications() async {
    const InitializationSettings _initSettings = InitializationSettings(
      android: AndroidInitializationSettings("icon_name"),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotificationsPlugin.initialize(
      _initSettings,
      onDidReceiveNotificationResponse: (details) {
        selectNotification(details.payload ?? '');
      },
    );

    /// need this for ios foregournd notification
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  NotificationDetails platformChannelSpecifics = const NotificationDetails(
    android: AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      priority: Priority.max,
      importance: Importance.max,
    ),
  );

  void selectNotification(String payload) async {}

  Future<dynamic> onMessage(RemoteMessage message) async {
    await _localNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
    final guestId = message.data['guestId'];
    if (guestId != null) {
      // Navigate to guest screen detail
      _messageStreamController.sink.add(guestId);
    }
  }

  Future<dynamic> onLaunch(RemoteMessage message) async {
    final guestId = message.data['guestId'];
    if (guestId != null) {
      // Navigate to guest screen detail
      _messageStreamController.sink.add(guestId);
    }
  }

  Future<dynamic> onResume(RemoteMessage message) async {
    final guestId = message.data['guestId'];
    if (guestId != null) {
      _messageStreamController.sink.add(guestId);
    }
  }
}
