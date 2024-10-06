import 'package:chat_rtc/src/features/rooms/controllers/room_controller.dart';
import 'package:chat_rtc/src/features/rooms/controllers/room_details_controller.dart';
import 'package:get/get.dart';

class RoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomsController>(() => RoomsController());
    Get.lazyPut<RoomDetailsController>(() => RoomDetailsController());
  }
}
