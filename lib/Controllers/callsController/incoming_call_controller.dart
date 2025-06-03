import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_call_app/Views/callScreen/calling_screen.dart';

class IncomingCallController extends GetxController {
  final String caller;
  final String channelId;
  final VoidCallback? onCallScreenClosed;

  IncomingCallController({
    required this.caller,
    required this.channelId,
    this.onCallScreenClosed,
  });

  Timer? _timeoutTimer;

  @override
  void onInit() {
    super.onInit();
    _startTimeout();
  }

  void _startTimeout() {
    _timeoutTimer = Timer(Duration(seconds: 30), () async {
      await updateCallStatus("missed");
      onCallScreenClosed?.call();
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }

  void cancelTimer() {
    _timeoutTimer?.cancel();
  }

  Future<void> updateCallStatus(String status) async {
    final callRef = FirebaseFirestore.instance.collection('calls').doc(channelId);
    final docSnapshot = await callRef.get();

    if (docSnapshot.exists) {
      await callRef.update({'status': status});
    } else {
      await callRef.set({'status': status});
      print("⚠️ Document not found. Created with status: $status");
    }
  }

  Future<void> acceptCall() async {
    cancelTimer();
    await updateCallStatus("accepted");
    onCallScreenClosed?.call();
    Get.to(() => CallPage(channelName: "test",channelId: channelId,));
  }

  Future<void> rejectCall() async {
    cancelTimer();
    await updateCallStatus("rejected");
    onCallScreenClosed?.call();
    Get.back();
  }

  Future<bool> handleBackPressed() async {
    await updateCallStatus("rejected");
    onCallScreenClosed?.call();
    return true;
  }

  @override
  void onClose() {
    cancelTimer();
    super.onClose();
  }
}
