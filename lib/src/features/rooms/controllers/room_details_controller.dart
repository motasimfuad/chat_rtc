import 'package:get/get.dart';

import '../models/room_model.dart';

class RoomDetailsController extends GetxController {
  // ignore: cast_from_null_always_fails
  final Rx<Room?> selectedRoom = (null as Room?).obs;

  void setRoom(Room newRoom) {
    selectedRoom.value = newRoom;
  }
}
