import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:video_call_app/LocalStorage/local_storage.dart';
import 'package:video_call_app/Utils/Routes/route.dart';
import 'package:video_call_app/Views/home_screen.dart';

class UserSelectionController extends GetxController {
  Future<void> selectUser(String userId, String otherUser) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");

    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': fcmToken,
      });

      LocalStorageService.saveLoggedUser(userId);
      LocalStorageService.saveOtherUser(otherUser);

      Get.to(()=>HomeScreen(userId: userId, otherUser: otherUser));
    } else {
      print('✅ FCM Token not found');
    }
  }}