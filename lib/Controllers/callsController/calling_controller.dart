// lib/controllers/call_controller.dart
import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_call_app/Utils/Routes/route.dart';
import 'package:video_call_app/Views/home_screen.dart';

class CallController extends GetxController {
  final String channelName;
  final channelId;
  CallController(this.channelName,this.channelId);

  static const String appId = '6897f9b3d7bb446a86ca5a36e2088547';
  static const String token = "007eJxTYJg+edmBHqenbVON+9ZZVGo8lH7jqMtucOy1Env5Fdufm0wVGMwsLM3TLJOMU8yTkkxMzBItzJITTRONzVKNDCwsTE3MbyfZZTQEMjLIhTayMjJAIIjPwlCSWlzCwAAAM0Qedg==";

  late RtcEngine _engine;
  late int _localUid;

  var localUserJoined = false.obs;
  var remoteUid = RxnInt();
  var isMuted = false.obs;
  var isFrontCamera = true.obs;

  late StreamSubscription<DocumentSnapshot> _callListener;

  @override
  void onInit() {
    super.onInit();
    initAgora();
    _listenToCallEnd();
  }

  Future<void> _createCallStatus() async {
    await FirebaseFirestore.instance.collection("calls").doc(channelId).set({
      "isActive": true,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _listenToCallEnd() {
    _callListener = FirebaseFirestore.instance
        .collection("calls")
        .doc(channelId)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data()?["isActive"] == false) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.isDialogOpen ?? false) Get.back();
          if (Get.isSnackbarOpen ?? false) Get.back();
          Get.offAndToNamed(AppRoutes.homeScreenRoute,arguments: "User");
        });
      }
    });
  }

  Future<void> initAgora() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      Get.snackbar("Permission Required", "Camera & Microphone permission required");
      return;
    }

    _localUid = Random().nextInt(100000);

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    await _createCallStatus();
    await _engine.enableVideo();
    await _engine.startPreview();

    localUserJoined.value = true;

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          localUserJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          this.remoteUid.value = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          this.remoteUid.value = null;
        },
        onError: (ErrorCodeType errCode, String errMsg) {
          debugPrint('Agora Error: $errCode - $errMsg');
        },
      ),
    );

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: _localUid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    _engine.muteLocalAudioStream(isMuted.value);
  }

  void switchCamera() {
    _engine.switchCamera();
    isFrontCamera.value = !isFrontCamera.value;
  }

  Future<void> endCall() async {
    await FirebaseFirestore.instance
        .collection("calls")
        .doc(channelId)
        .update({"isActive": false});
    Get.offAll(()=>HomeScreen(userId: "User", otherUser: "User"));
  }


  AgoraVideoView getLocalView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: 0),
      ),
    );
  }

  AgoraVideoView getRemoteView(int uid) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: channelName),
      ),
    );
  }

  @override
  void onClose() {
    _callListener.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.onClose();
  }
}
