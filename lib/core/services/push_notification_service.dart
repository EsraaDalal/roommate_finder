import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/presentation/pages/notifications_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Notification Received in Background ${message.messageId}");
}

class PushNotificationService {
  PushNotificationService._internal();

  static final PushNotificationService _instance =
      PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription? _notificationsSubscription;
  DateTime _serviceStartTime = DateTime.now();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'roommate_finder_channel',
    'Roommate Finder Notifications',
    description: 'Notifications for applications, status updates, and messages',
    importance: Importance.max,
  );

  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    _navigatorKey = navigatorKey;
    _serviceStartTime = DateTime.now();

    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      log("Could not register onBackgroundMessage: $e");
    }

    await _requestPermission();
    await _setupLocalNotifications();
    _listenToMessages();
    await _checkForInitialMessage();
  }

  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      log('User Permission Status: ${settings.authorizationStatus}');
    } catch (e) {
      log('Error requesting push permission: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      String? token = await _fcm.getToken();
      log("FCM Token: $token");
      return token;
    } catch (e) {
      log("Failed to get FCM Token: $e");
      return null;
    }
  }

  Future<void> syncUserToken(String userId) async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        log('Failed to save FCM token to Firestore: $e');
      }
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        log('Failed to update refreshed FCM token: $e');
      }
    });

    // Start listening to real-time notifications to trigger local popups
    _startRealtimeNotificationListener(userId);
  }

  void _startRealtimeNotificationListener(String userId) {
    _notificationsSubscription?.cancel();

    _notificationsSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final isRead = data['isRead'] as bool? ?? false;
          final createdAtRaw = data['createdAt'];
          DateTime? createdAt;
          if (createdAtRaw is Timestamp) {
            createdAt = createdAtRaw.toDate();
          }

          // Show local notification if not read and arrived recently
          if (!isRead &&
              createdAt != null &&
              createdAt.isAfter(
                _serviceStartTime.subtract(const Duration(seconds: 10)),
              )) {
            final title = data['title'] as String? ?? 'New Notification';
            final body = data['body'] as String? ?? '';
            showLocalNotificationDirect(
              id: change.doc.id.hashCode,
              title: title,
              body: body,
              payload: change.doc.id,
            );
          }
        }
      }
    });
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Local Notification was pressed: ${response.payload}");
        _handleNotificationTap(data: {"payload": response.payload});
      },
    );

    final androidImplementation =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(_channel);
  }

  void _listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Notification received while app in foreground");
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification clicked while app in background");
      _handleNotificationTap(message: message);
    });
  }

  Future<void> _checkForInitialMessage() async {
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log("Notification clicked and app was terminated");
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(message: initialMessage);
      });
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Roommate Finder',
      body: message.notification?.body ?? '',
      notificationDetails: platformDetails,
      payload: message.data.toString(),
    );
  }

  Future<void> showLocalNotificationDirect({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  void _handleNotificationTap({
    Map<dynamic, dynamic>? data,
    RemoteMessage? message,
  }) {
    if (data == null && message == null) return;
    _navigatorKey?.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationsPage(),
      ),
    );
  }

  void dispose() {
    _notificationsSubscription?.cancel();
  }
}
