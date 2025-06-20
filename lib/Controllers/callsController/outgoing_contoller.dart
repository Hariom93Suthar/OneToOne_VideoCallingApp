// outgoing_call_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_call_app/LocalStorage/local_storage.dart';
import 'package:video_call_app/Views/home_screen.dart';
import '../../Views/callScreen/calling_screen.dart';

class OutgoingCallController extends GetxController {
  final String channelId;
  final String? callerName;
  final String? receiverName;
  final BuildContext context;

  StreamSubscription<DocumentSnapshot>? _callStatusSubscription;
  StreamSubscription<DocumentSnapshot>? _callTimeoutSubscription;

  OutgoingCallController({
    required this.channelId,
    required this.context,
    required this.callerName,
    required this.receiverName,
  });

  @override
  void onInit() {
    super.onInit();
    _listenToCallStatus();
    _startCallTimeoutListener();
    _logCallData();
  }

  void _startCallTimeoutListener() {
    _callTimeoutSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(channelId)
        .snapshots()
        .listen((doc) async {
      if (!doc.exists) return;

      final data = doc.data();
      final status = data?['status'];
      final Timestamp? createdAt = data?['createdAt'];

      if (status != 'accepted' && status != 'rejected' && status != 'ended') {
        if (createdAt != null) {
          final currentTime = DateTime.now();
          final callTime = createdAt.toDate();
          final difference = currentTime.difference(callTime);

          if (difference.inSeconds >= 30) {
            await FirebaseFirestore.instance
                .collection('calls')
                .doc(channelId)
                .set({'status': 'ended'}, SetOptions(merge: true));

            await _updateCallLogStatus('missed');

            final userId = LocalStorageService.getLoggedUser();
            final otherUser = LocalStorageService.getOtherUser();

            print("🕑 Call timeout. Navigating to Home. userId: $userId, otherUser: $otherUser");

            if (userId != null && otherUser != null) {
              if (context.mounted) {
                Get.offAll(() => HomeScreen(userId: userId, otherUser: otherUser));
              }
            }
          }
        }
      }
    });
  }

  void _listenToCallStatus() {
    _callStatusSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(channelId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data();
      final status = data?['status'];

      if (status == 'accepted') {
        _updateCallLogStatus('accepted');
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallPage(channelName: "test", channelId: channelId),
            ),
          );
        }
      } else if (status == 'rejected' || status == 'ended') {
        _updateCallLogStatus(status ?? 'ended');

        final userId = LocalStorageService.getLoggedUser();
        final otherUser = LocalStorageService.getOtherUser();

        if (userId != null && otherUser != null) {
          if (context.mounted) {
            Get.offAll(() => HomeScreen(userId: userId, otherUser: otherUser));
          }
        } else {
          print("⚠️ Can't go to Home, user info missing.");
        }
      }
    });
  }

  Future<void> endCall() async {
    try {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(channelId)
          .set({'status': 'ended'}, SetOptions(merge: true));

      await _updateCallLogStatus('ended');

      final userId = LocalStorageService.getLoggedUser();
      final otherUser = LocalStorageService.getOtherUser();

      if (userId != null && otherUser != null) {
        if (context.mounted) {
          Get.offAll(() => HomeScreen(userId: userId, otherUser: otherUser));
        }
      }
    } catch (e) {
      print("❌ Failed to end call: $e");
    }
  }

  Future<void> _logCallData() async {
    try {
      final callDocRef = FirebaseFirestore.instance.collection('callLogs').doc(channelId);
      await callDocRef.set({
        'caller': callerName,
        'receiver': LocalStorageService.getLoggedUser(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'calling',
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Failed to log call data: $e");
    }
  }

  Future<void> _updateCallLogStatus(String status) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance.collection('calls').doc(channelId).set({
        'status': status,
        'updatedAt': timestamp,
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('callLogs').doc(channelId).set({
        'status': status,
        'updatedAt': timestamp,
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Failed to update call log status: $e");
    }
  }

  @override
  void onClose() {
    _callStatusSubscription?.cancel();
    _callTimeoutSubscription?.cancel();
    super.onClose();
  }
}
