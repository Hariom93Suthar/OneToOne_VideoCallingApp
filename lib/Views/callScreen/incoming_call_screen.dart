import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_call_app/Controllers/callsController/incoming_call_controller.dart';

class IncomingCallScreen extends StatelessWidget {
  final String caller;
  final String channelId;
  final VoidCallback? onCallScreenClosed;

  const IncomingCallScreen({
    required this.caller,
    required this.channelId,
    this.onCallScreenClosed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      IncomingCallController(
        caller: caller,
        channelId: channelId,
        onCallScreenClosed: onCallScreenClosed,
      ),
    );

    return WillPopScope(
      onWillPop: controller.handleBackPressed,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 20),
              Text(
                "$caller is calling you...",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              CircleAvatar(
                radius: 80,
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.graphic_eq, color: Colors.greenAccent, size: 30),
                  SizedBox(width: 10),
                  Icon(Icons.graphic_eq, color: Colors.orangeAccent, size: 30),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "accept",
                    backgroundColor: Colors.green,
                    onPressed: controller.acceptCall,
                    child: Icon(Icons.videocam, size: 30),
                  ),
                  FloatingActionButton(
                    heroTag: "reject",
                    backgroundColor: Colors.red,
                    onPressed: controller.rejectCall,
                    child: Icon(Icons.call_end, size: 30),
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
