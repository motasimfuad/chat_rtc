import 'package:chat_rtc/src/features/chat/controllers/call_controller.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final CallController callController = Get.find<CallController>();

  String? roomId;
  String? targetUserEmail;
  String? senderEmail;

  @override
  void onInit() {
    super.onInit();
    ever(callController.webRTCService.firebaseData, (_) {
      callController.checkForIncomingCall();
    });
  }

  Future<void> initializeChat(
    String roomId,
    String userEmail,
    String targetUserEmail,
  ) async {
    this.roomId = roomId;
    senderEmail = userEmail;
    this.targetUserEmail = targetUserEmail;

    await callController.initializeCall(
      roomId,
      senderEmail!,
      targetUserEmail,
    );
  }
}
