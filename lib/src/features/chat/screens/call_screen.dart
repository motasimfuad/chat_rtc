import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

class CallScreen extends GetView<CallController> {
  const CallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.callTargetUserEmail ?? 'Call'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildVideoView(isLocal: false),
                  Positioned(
                    top: 20,
                    right: 10,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          child: _buildVideoView(isLocal: true),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoView({required bool isLocal}) {
    return Obx(() {
      final renderer = isLocal
          ? controller.webRTCService.localRenderer.value
          : controller.webRTCService.remoteRenderer.value;
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: isLocal
              ? BorderRadius.circular(
                  12,
                )
              : null,
          border: isLocal
              ? Border.all(
                  color: Colors.white,
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RTCVideoView(
              renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isLocal
                      ? 'You'
                      : (controller.callTargetUserEmail ?? 'Remote'),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.call_end,
                color: Colors.white,
              ),
              onPressed: () => controller.endCall(),
            ),
          ),
        ],
      ),
    );
  }
}
