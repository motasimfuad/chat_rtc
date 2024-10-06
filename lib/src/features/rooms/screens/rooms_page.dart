import 'package:chat_rtc/src/core/theme/app_colors.dart';
import 'package:chat_rtc/src/features/rooms/widgets/room_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/authentication/controllers/auth_controller.dart';
import '../controllers/room_controller.dart';

class RoomsPage extends GetView<RoomsController> {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '${authController.currentUser!.email}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchRooms,
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: controller.rooms.length,
              itemBuilder: (BuildContext context, int index) {
                final room = controller.rooms[index];
                return RoomCard(
                  room: room,
                  userId: authController.currentUser!.uid,
                  onJoin: () => controller.joinRoom(room.id),
                  onTap: () {},
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
