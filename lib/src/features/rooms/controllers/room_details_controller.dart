import 'package:chat_rtc/src/features/authentication/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../models/room_model.dart';

class RoomDetailsController extends GetxController {
  final Rx<Room?> selectedRoom = (null as Room?).obs;
  final AuthController authController = Get.find<AuthController>();

  void setRoom(Room newRoom) {
    selectedRoom.value = newRoom;
  }
}
