// lib/views/call_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/callsController/calling_controller.dart';

class CallPage extends StatelessWidget {
  final String channelName;
  final channelId;

  const CallPage({Key? key, required this.channelName,required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CallController controller = Get.put(CallController(channelName,channelId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return Stack(
          children: [
            controller.remoteUid.value != null
                ? controller.getRemoteView(controller.remoteUid.value!)
                : const Center(
              child: Text('📞 Waiting for user to join...',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ),

            if (controller.localUserJoined.value)
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 120,
                  height: 160,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: controller.getLocalView(),
                  ),
                ),
              ),

            // End Call Button
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: controller.endCall,
                child: const Icon(Icons.call_end),
              ),
            ),

            // Mute Toggle
            Positioned(
              bottom: 40,
              left: 30,
              child: FloatingActionButton(
                backgroundColor: Colors.grey.shade800,
                onPressed: controller.toggleMute,
                child: Obx(() => Icon(controller.isMuted.value ? Icons.mic_off : Icons.mic)),
              ),
            ),

            // Camera Flip
            Positioned(
              bottom: 40,
              right: 30,
              child: FloatingActionButton(
                backgroundColor: Colors.grey.shade800,
                onPressed: controller.switchCamera,
                child: const Icon(Icons.cameraswitch),
              ),
            ),
          ],
        );
      }),
    );
  }
}
