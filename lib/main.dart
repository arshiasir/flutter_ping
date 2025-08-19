import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/ui/theme.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/network_service.dart';
import 'app/data/services/flutter_service.dart';
import 'app/data/services/android_service.dart';
import 'app/data/services/version_service.dart';

void main() {
  // Initialize services
  _initializeServices();

  runApp(const FlutterPingApp());
}

void _initializeServices() {
  // Register services with GetX dependency injection
  Get.put(NetworkService(), permanent: true);
  Get.put(FlutterService(), permanent: true);
  Get.put(AndroidService(), permanent: true);
  Get.put(VersionService(), permanent: true);
}

class FlutterPingApp extends StatelessWidget {
  const FlutterPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Ping',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
