import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../Views/callScreen/incoming_call_screen.dart';
import '../controllers/call_controller.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static RemoteMessage? _lastCallMessage;

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'ACCEPT_CALL') {
          _handleCall();
        } else if (response.actionId == 'DECLINE_CALL') {
          // Decline logic here
        } else if (response.payload == 'incoming_call') {
          _handleCall();
        }
      },
    );
  }

  static void showIncomingCallNotification(RemoteMessage message) async {
    _lastCallMessage = message;

    const androidDetails = AndroidNotificationDetails(
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
      actions: [
        AndroidNotificationAction('ACCEPT_CALL', 'Accept', cancelNotification: true),
        AndroidNotificationAction('DECLINE_CALL', 'Decline', cancelNotification: true),
      ],
    );

    const details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      100,
      'Incoming Call',
      '${message.data['caller'] ?? 'Someone'} is calling...',
      details,
      payload: 'incoming_call',
    );
  }

  static void _handleCall() {
    if (Get.find<CallController>().isCallScreenShown.value) return;

    final data = _lastCallMessage?.data ?? {};
    final caller = data['caller'] ?? 'Unknown';
    final channelId = data['channelId'] ?? 'test';

    Get.find<CallController>().isCallScreenShown.value = true;

    Get.to(() => IncomingCallScreen(
      caller: caller,
      channelId: channelId,
      onCallScreenClosed: () {
        Get.find<CallController>().isCallScreenShown.value = false;
      },
    ));
  }
}
