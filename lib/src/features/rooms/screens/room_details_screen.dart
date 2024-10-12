import 'package:chat_rtc/src/core/routes/app_routes.dart';
import 'package:chat_rtc/src/features/authentication/controllers/auth_controller.dart';
import 'package:chat_rtc/src/features/rooms/controllers/room_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/room_details_controller.dart';

class RoomDetailsScreen extends GetView<RoomDetailsController> {
  RoomDetailsScreen({
    super.key,
  }) {
    final room = Get.find<RoomsController>().roomDetails.value;
    if (room != null) {
      controller.setRoom(room);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedRoom.value?.name ?? 'N/A',
          ),
        ),
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final room = controller.selectedRoom.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Users:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  itemCount: room?.users.length ?? 0,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final userEmail = room?.users[index] ?? 'N/A';
                    final myEmail =
                        Get.find<AuthController>().currentUser?.email;
                    bool loggedInUser = userEmail == myEmail;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.primary,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        tileColor: AppColors.primary,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.shade900,
                          child: Text(
                            userEmail[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          (loggedInUser) ? '$userEmail (You)' : userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        ),
                        onTap: loggedInUser
                            ? null
                            : () {
                                Get.toNamed(
                                  AppRoutes.chat,
                                  arguments: [
                                    room?.id,
                                    myEmail,
                                    userEmail,
                                  ],
                                );
                              },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
