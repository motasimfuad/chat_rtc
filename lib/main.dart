import 'package:chat_rtc/src/core/routes/app_pages.dart';
import 'package:chat_rtc/src/core/routes/app_routes.dart';
import 'package:chat_rtc/src/core/services/cache/cache_service.dart';
import 'package:chat_rtc/src/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CacheService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat RTC',
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
