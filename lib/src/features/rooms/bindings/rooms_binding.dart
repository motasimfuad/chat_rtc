import 'package:get/get.dart';

import '../controllers/room_controller.dart';
import '../repositories/rooms_repository.dart';

class RoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomsRepository>(() => RoomsRepository());
    Get.lazyPut<RoomsController>(() => RoomsController());
  }
}
