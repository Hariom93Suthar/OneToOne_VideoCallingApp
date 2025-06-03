import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../Views/callScreen/incoming_call_screen.dart';
import '../main.dart';

@pragma('vm:entry-point')

class FirebaseMessagingService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static RemoteMessage? _lastCallMessage;
  bool _isIncomingCallScreenOpen = false;
  bool _hasNavigatedToCall = false; // ✅ Prevent double navigation

  /// Background handler (static)
  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('📥 (BG Handler) Message received: ${message.data}');

    // ✅ Manually initialize FlutterLocalNotificationsPlugin
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'call_channel',
      'Incoming Call',
      channelDescription: 'For showing call notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      ongoing: true,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'ACCEPT_CALL',
          'Accept',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'DECLINE_CALL',
          'Decline',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      100,
      'Incoming Call',
      '${message.data['caller'] ?? 'Someone'} is calling...',
      platformDetails,
      payload: 'incoming_call',
    );
  }
  Future<FirebaseMessagingService> init() async {
    await _initializeLocalNotifications();

    NotificationSettings settings = await _messaging.requestPermission();
    print('🔐 Permission granted: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((message) {
      print('📩 Foreground Notification: ${message.data}');
      _showIncomingCallNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('📬 Notification Clicked: ${message.data}');
      _handleNotificationSafely(message);
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('💤 App opened from terminated: ${initialMessage.data}');
      await Future.delayed(Duration(milliseconds: 800));
      _handleNotificationSafely(initialMessage);
    }

    return this;
  }

  // ✅ Safe version with delayed navigation and flag
  void _handleNotificationSafely(RemoteMessage message) {
    if (_hasNavigatedToCall) return;
    _hasNavigatedToCall = true;

    final data = message.data;
    final caller = data['caller'];
    final channelId = data['channelId'];

    if (caller != null && channelId != null && !_isIncomingCallScreenOpen) {
      _isIncomingCallScreenOpen = true;

      // Delay a bit to make sure UI is mounted
      Future.delayed(Duration(milliseconds: 300), () {
        if (navigatorKey.currentState?.mounted ?? false) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => IncomingCallScreen(
                caller: caller,
                channelId: channelId,
                onCallScreenClosed: () {
                  _isIncomingCallScreenOpen = false;
                  _hasNavigatedToCall = false; // Reset
                },
              ),
            ),
          );
        } else {
          _isIncomingCallScreenOpen = false;
          _hasNavigatedToCall = false;
        }
      });
    }
  }

  // ✅ Local Notification Button Tap Handler
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'ACCEPT_CALL') {
          print('☎️ Call Accepted');
          if (_lastCallMessage != null) {
            _handleNotificationSafely(_lastCallMessage!);
          }
        } else if (response.actionId == 'DECLINE_CALL') {
          print('📵 Call Declined');
        } else if (response.payload == 'incoming_call') {
          if (_lastCallMessage != null) {
            _handleNotificationSafely(_lastCallMessage!);
          }
        }
      },
    );
  }

  // ✅ Still used in foreground to show call notification
  void _showIncomingCallNotification(RemoteMessage message) async {
    _lastCallMessage = message;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'call_channel',
      'Incoming Call',
      channelDescription: 'For showing call notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      ongoing: true,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'ACCEPT_CALL',
          'Accept',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'DECLINE_CALL',
          'Decline',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      100,
      'Incoming Call',
      '${message.data['caller'] ?? 'Someone'} is calling...',
      platformDetails,
      payload: 'incoming_call',
    );
  }
}

