import 'dart:async';
import 'dart:developer';

import 'package:chat_rtc/src/core/routes/app_routes.dart';
import 'package:chat_rtc/src/core/services/webrtc/webrtc_service.dart';
import 'package:chat_rtc/src/features/chat/widgets/incoming_call_dialog.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class CallController extends GetxController {
  final WebRTCService webRTCService = WebRTCService();

  final RxBool isCallReady = false.obs;
  final RxBool isCallInitialized = false.obs;
  final RxString errorMessage = ''.obs;

  String? callRoomId;
  String? callUserEmail;
  String? callTargetUserEmail;

  @override
  void onInit() {
    super.onInit();
    ever(webRTCService.callState, onCallStateChanged);
  }

  Future<void> initiateCall() async {
    try {
      Get.toNamed(AppRoutes.callSetup);
      await webRTCService.startCall();
      if (webRTCService.isInitiator) {
        await webRTCService.createAndStoreOffer();
      }
    } catch (e) {
      log('Error initiating call: $e');
      errorMessage.value = 'Failed to initiate call: $e';
    }
  }

  Future<void> initializeCall(
    String roomId,
    String userEmail,
    String targetUserEmail,
  ) async {
    try {
      await webRTCService.initialize(
        roomId,
        userEmail,
        targetUserEmail,
      );
      callRoomId = roomId;
      callUserEmail = userEmail;
      callTargetUserEmail = targetUserEmail;
      isCallReady.value = true;
      isCallInitialized.value = true;

      if (!webRTCService.isInitiator &&
          webRTCService.firebaseData['offer'] != null) {
        await webRTCService.handleStoredOffer();
        Get.toNamed(AppRoutes.callSetup);
      }
    } catch (e) {
      log('Error initializing call: $e');
      errorMessage.value = 'Failed to initialize call: $e';
    }
  }

  void checkForIncomingCall() {
    if (webRTCService.firebaseData['offer'] != null &&
        !webRTCService.isInitiator &&
        !Get.isDialogOpen! &&
        (webRTCService.callState.value != CallState.answerCreated ||
            webRTCService.callState.value != CallState.connected)) {
      showIncomingCallDialog().then((answered) {
        if (answered) {
          handleAnswerCall();
        } else {
          handleRejectCall();
        }
      });
    }
  }

  Future<bool> showIncomingCallDialog() async {
    final result = await Get.dialog<bool>(
      IncomingCallDialog(
        callerName: webRTCService.targetUserEmail ?? 'Unknown',
        onAnswer: () {
          Get.back(result: true);
        },
        onReject: () {
          Get.back(result: false);
        },
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  Future<void> handleAnswerCall() async {
    try {
      await webRTCService.handleAnswerCall();
    } catch (e) {
      log('Error answering call: $e');
      errorMessage.value = 'Failed to answer call: $e';
    }
  }

  Future<void> handleRejectCall() async {
    try {
      await webRTCService.handleRejectCall();
      Get.back();
    } catch (e) {
      log('Error rejecting call: $e');
      errorMessage.value = 'Failed to reject call: $e';
    }
  }

  CallState get callState => webRTCService.callState.value;
  Rx<RTCVideoRenderer> get localRenderer => webRTCService.localRenderer;
  Rx<RTCVideoRenderer> get remoteRenderer => webRTCService.remoteRenderer;
  bool get isInitiator => webRTCService.isInitiator;

  void onCallStateChanged(CallState newState) {
    log('Call state changed to: $newState');
    if (newState == CallState.connected) {
      Get.toNamed(AppRoutes.call);
    }
  }

  Future<void> joinCall() async {
    try {
      if (webRTCService.isInitiator) {
        await webRTCService.handleStoredAnswer();
      }
      Get.toNamed(AppRoutes.call);
    } catch (e) {
      log('Error joining call: $e');
      errorMessage.value = 'Failed to join call: $e';
    }
  }

  Future<void> endCall() async {
    try {
      await webRTCService.endCall();
      Get.back();
    } catch (e) {
      log('Error ending call: $e');
      errorMessage.value = 'Failed to end call: $e';
    }
  }

  @override
  void onClose() {
    webRTCService.dispose();
    super.onClose();
  }
}
