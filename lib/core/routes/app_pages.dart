import 'package:chat_rtc/src/features/authentication/bindings/auth_binding.dart';
import 'package:chat_rtc/src/features/authentication/screens/login_screen.dart';
import 'package:chat_rtc/src/features/authentication/screens/signup_screen.dart';
import 'package:chat_rtc/src/features/authentication/screens/splash_screen.dart';
import 'package:chat_rtc/src/features/rooms/screens/rooms_page.dart';
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
      page: () => const RoomsPage(),
    ),
  ];
}
