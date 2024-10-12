import 'package:chat_rtc/src/core/services/webrtc/webrtc_service.dart';
import 'package:chat_rtc/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

class CallSetupScreen extends GetView<CallController> {
  const CallSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calling...')),
      body: Center(
        child: Obx(() {
          final connected = controller.callState == CallState.connected;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Calling...'),
              Text(
                controller.callTargetUserEmail ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text('Call State: ${controller.callState}'),
              const SizedBox(height: 120),
              if (controller.isInitiator)
                Text(controller.callState == CallState.waitingForAnswer
                    ? 'Login as the receiver to join the call'
                    : 'Ready to join the call'),
              if (!controller.isInitiator)
                Text(controller.callState == CallState.waitingForInitiator
                    ? 'Login as the initiator to start the call'
                    : 'Ready to join the call'),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      color: AppColors.white,
                      onPressed: controller.handleRejectCall,
                      icon: const Icon(Icons.call_end),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: connected
                          ? AppColors.success
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      color: AppColors.white,
                      onPressed:
                          connected ? () => controller.joinCall() : () {},
                      icon: const Icon(Icons.call),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
