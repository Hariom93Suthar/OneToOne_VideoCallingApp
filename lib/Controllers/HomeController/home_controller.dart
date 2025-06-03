import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:video_call_app/secrete/jsondata.dart';

class HomeCallController extends GetxController {
  final String? userId;

  HomeCallController(this.userId);

  final serviceAccountJson = Secrete.serviceAccountJsonData;   // This is store in secure file for protective


  String get otherUserId => userId == 'userA' ? 'userB' : 'userA';

  Future<String?> sendCallNotification() async {
    try {
      final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);

      final doc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final token = data?['fcmToken'];
      final channelId = 'call_${DateTime.now().millisecondsSinceEpoch}';

      if (token == null) {
        print("FCM token not found for $otherUserId");
        return null;
      }

      final body = {
        "message": {
          "token": token,
          "data": {
            "type": "call",
            "caller": userId,
            "channelId": channelId,
            "title": "Incoming Call",
            "body": "$userId is calling you",
          },
          "android": {
            "notification": {
              "sound": "default",
            },
          },
          "apns": {
            "payload": {
              "aps": {
                "sound": "default",
              },
            },
          },
        }
      };

      final projectId = 'video-callapp-c0572';
      final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      client.close();

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
        return channelId;
      } else {
        print('❌ Failed to send notification: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('🔥 Error sending notification: $e');
      return null;
    }
  }
}
