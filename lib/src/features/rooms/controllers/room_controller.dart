import 'package:chat_rtc/src/features/authentication/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../models/room_model.dart';
import '../repositories/rooms_repository.dart';

class RoomsController extends GetxController {
  final RoomsRepository _roomRepository = RoomsRepository();
  final userEmail = Get.find<AuthController>().currentUser?.email;
  final RxList<Room> rooms = <Room>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  Future<void> fetchRooms({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    try {
      rooms.value = await _roomRepository.getRooms();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch rooms: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      if (userEmail == null) {
        Get.snackbar(
          'Error',
          'User not authenticated',
        );
        return;
      }
      bool success = await _roomRepository.joinRoom(roomId, userEmail!);
      if (success) {
        await fetchRooms(showLoading: false);
        Get.snackbar(
          'Success',
          'Joined room successfully',
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to join room',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to join room: $e',
      );
    }
  }
}
