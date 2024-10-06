import 'package:chat_rtc/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/room_model.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final String userId;
  final Function()? onTap;
  final Function()? onJoin;

  const RoomCard({
    Key? key,
    required this.room,
    required this.userId,
    required this.onTap,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (room.userJoined(userId)) ? onTap : null,
      child: Card(
        elevation: 0.5,
        shadowColor: AppColors.primary.shade600,
        color: AppColors.primary.shade500,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: AppColors.primary.shade600,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(15).copyWith(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${room.users.length} Users',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!room.userJoined(userId))
                    IconButton(
                      onPressed: onJoin,
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 30,
                        color: Colors.deepPurple,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
