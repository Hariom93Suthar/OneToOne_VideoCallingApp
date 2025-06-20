import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Services/firebase_messaging_service.dart';
import '../Utils/Routes/route.dart';


class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    handleStartupLogic();
  }

  Future<void> handleStartupLogic() async {
    await Future.delayed(const Duration(milliseconds: 800));

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.offAllNamed(AppRoutes.onBordingRoute);
    } else {
      if (initialMessage != null && initialMessage.data['type'] == 'call') {
        print("📲 Opening call from terminated state: ${initialMessage.data}");
        await Get.find<FirebaseMessagingService>().handleNotificationSafely(initialMessage); // ✅ fix
      }
      Get.offAllNamed(AppRoutes.homeScreenRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
