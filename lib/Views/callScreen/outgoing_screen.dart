// calling_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_call_app/Controllers/callsController/outgoing_contoller.dart';

class CallingScreen extends StatefulWidget {
  final String? calleeName;
  final String channelId;
  final String? recivedUser;

  const CallingScreen({
    required this.calleeName,
    required this.channelId,
    required this.recivedUser,
    Key? key,
  }) : super(key: key);

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  late OutgoingCallController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      OutgoingCallController(channelId: widget.channelId, context: context,receiverName: widget.recivedUser,callerName: widget.calleeName),
    );
  }

  @override
  void dispose() {
    Get.delete<OutgoingCallController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Outgoing screen channle Id is: ${widget.channelId}");

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 👤 Placeholder video background
          Positioned.fill(
            child: Image.asset(
              'assets/images/blurred-pub.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 🔲 Overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 🧍 Caller info & animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Connecting Video Call...",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 22,
                        fontWeight: FontWeight.w300)),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person,color: Colors.white,)
                ),
                SizedBox(height: 16),
                Text(widget.calleeName ?? 'User',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 30),
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // ❌ End button
          Positioned(
            bottom: 60,
            left: MediaQuery.of(context).size.width * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            child: ElevatedButton.icon(
              onPressed: controller.endCall,
              icon: Icon(Icons.call_end, color: Colors.white),
              label: Text("End Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
