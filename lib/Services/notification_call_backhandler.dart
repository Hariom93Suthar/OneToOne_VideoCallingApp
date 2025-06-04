// lib/Services/notification_callback_handler.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  await Firebase.initializeApp();

  if (notificationResponse.actionId == 'ACCEPT_CALL') {
    print('✅ [BG] Accept button tapped');
    // Store info or trigger call logic here
  } else if (notificationResponse.actionId == 'DECLINE_CALL') {
    print('❌ [BG] Decline button tapped');
    // Cancel or ignore
  }
}
