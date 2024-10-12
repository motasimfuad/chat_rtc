import 'package:chat_rtc/src/features/authentication/bindings/auth_binding.dart';
import 'package:chat_rtc/src/features/authentication/screens/login_screen.dart';
import 'package:chat_rtc/src/features/authentication/screens/signup_screen.dart';
import 'package:chat_rtc/src/features/authentication/screens/splash_screen.dart';
import 'package:chat_rtc/src/features/chat/screens/chat_screen.dart';
import 'package:chat_rtc/src/features/rooms/bindings/rooms_binding.dart';
import 'package:chat_rtc/src/features/rooms/screens/room_details_screen.dart';
import 'package:chat_rtc/src/features/rooms/screens/rooms_screen.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.rooms,
      page: () => const RoomsScreen(),
      bindings: [
        RoomsBinding(),
        AuthBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.roomDetails,
      page: () => RoomDetailsScreen(),
      binding: RoomsBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => ChatScreen(),
      bindings: [
        RoomsBinding(),
        CallBinding(),
      ],
    ),
  ];
}
