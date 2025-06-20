import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import '../Views/callScreen/calling_screen.dart'; // 🔄 Use your correct call screen

Future<void> showIncomingCall({
  required String caller,
  required String callId,
  required BuildContext context, // Needed to navigate
}) async {
  final params = CallKitParams(
    id: callId,
    nameCaller: caller,
    appName: 'VideoCall',
    handle: caller,
    type: 1, // 1 = video call
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      actionColor: '#4CAF50',
      incomingCallNotificationChannelName: 'Incoming Call',
    ),
    ios: IOSParams(iconName: 'AppIcon'),
  );

  // 🔔 Show native incoming call
  await FlutterCallkitIncoming.showCallkitIncoming(params);

  // 🔄 Listen to actions
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    if (event == null) return;

    switch (event.event) {
      case Event.actionCallAccept:
      case Event.actionCallCallback:
        print('✅ Call Accepted or Tapped');
        // Navigate to call screen
        Get.to(() => CallPage(
          channelName: "test", // pass actual values
          channelId: callId,
        ));
        break;

      case Event.actionCallDecline:
        print('❌ Call Declined');
        break;

      case Event.actionCallTimeout:
        print('⏰ Call Timeout');
        break;

      case Event.actionCallEnded:
        print('📞 Call Ended');
        break;

      default:
        print('⚠️ Unhandled CallKit event: ${event.event}');
    }
  });
}
