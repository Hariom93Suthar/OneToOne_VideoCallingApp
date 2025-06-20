import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_call_app/Services/call_kit.dart';
import 'package:video_call_app/Services/notification_call_backhandler.dart';
import 'package:video_call_app/main.dart';
import '../Views/callScreen/incoming_call_screen.dart';


@pragma('vm:entry-point')
class FirebaseMessagingService extends GetxService with WidgetsBindingObserver {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static RemoteMessage? _lastCallMessage;
  bool _isIncomingCallScreenOpen = false;
  bool _hasNavigatedToCall = false;

  AppLifecycleState _appState = AppLifecycleState.resumed; // 🔹 Track app state

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // 🔹 Start observing app state
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); // 🔹 Clean observer
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appState = state;
    print('📲 App state changed: $_appState');
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('📥 (BG Handler) Message received: ${message.data}');

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

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
        AndroidNotificationAction('ACCEPT_CALL', 'Accept',
            showsUserInterface: true, cancelNotification: true),
        AndroidNotificationAction('DECLINE_CALL', 'Decline',
            showsUserInterface: true, cancelNotification: true),
      ],
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

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
      if (!_isIncomingCallScreenOpen &&
          navigatorKey.currentState?.context != null) {
          handleNotificationSafely(message);
      } else {
        _showIncomingCallNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('📬 Notification Clicked: ${message.data}');
      handleNotificationSafely(message);
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('💤 App opened from terminated: ${initialMessage.data}');
      await Future.delayed(Duration(milliseconds: 800));
      handleNotificationSafely(initialMessage);
    }

    return this;
  }

  Future<void> handleNotificationSafely(RemoteMessage message) async {
    if (_hasNavigatedToCall) return;
    _hasNavigatedToCall = true;

    final data = message.data;
    final String caller = data['caller'];
    final String channelId = data['channelId'];

    print("'💤 '💤 '💤 ${data},${caller},${channelId}");

    if (caller != null && channelId != null && !_isIncomingCallScreenOpen) {
      _isIncomingCallScreenOpen = true;

      await Future.delayed(Duration(milliseconds: 200));
      final currentContext = navigatorKey.currentContext;

      if (_appState == AppLifecycleState.resumed &&
          navigatorKey.currentState?.mounted == true) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              caller: caller,
              channelId: channelId,
              onCallScreenClosed: () {
                _isIncomingCallScreenOpen = false;
                _hasNavigatedToCall = false;
              },
            ),
          ),
        );
      } else if (currentContext != null) {
        await showIncomingCall(
          caller: caller,
          callId: channelId,
          context: currentContext,
        );
        _isIncomingCallScreenOpen = false;
        _hasNavigatedToCall = false;
      } else {
        print('⚠️ context is null — unable to showIncomingCall right now.');
        _isIncomingCallScreenOpen = false;
        _hasNavigatedToCall = false;
      }
    }
  }

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
            handleNotificationSafely(_lastCallMessage!);
          }
        } else if (response.actionId == 'DECLINE_CALL') {
          print('📵 Call Declined');
        } else if (response.payload == 'incoming_call') {
          if (_lastCallMessage != null) {
            handleNotificationSafely(_lastCallMessage!);
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

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
        AndroidNotificationAction('ACCEPT_CALL', 'Accept',
            showsUserInterface: true, cancelNotification: true),
        AndroidNotificationAction('DECLINE_CALL', 'Decline',
            showsUserInterface: true, cancelNotification: true),
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
