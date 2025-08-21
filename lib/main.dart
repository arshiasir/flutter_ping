import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'app/ui/theme.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/network_service.dart';
import 'app/data/services/flutter_service.dart';
import 'app/data/services/android_service.dart';
import 'app/data/services/version_service.dart';
import 'app/data/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services
  await _initializeServices();

  runApp(const FlutterPingApp());

  // Configure bitsdojo_window for desktop platforms
  doWhenWindowReady(() {
    const initialSize = Size(600, 400);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Flutter Ping";
    appWindow.show();
  });
}

Future<void> _initializeServices() async {
  // Register services with GetX dependency injection
  Get.put(NetworkService(), permanent: true);
  Get.put(FlutterService(), permanent: true);
  Get.put(AndroidService(), permanent: true);
  Get.put(VersionService(), permanent: true);
  await Get.putAsync<ThemeService>(
    () async => await ThemeService().init(),
    permanent: true,
  );
}

class FlutterPingApp extends StatelessWidget {
  const FlutterPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();
    return Obx(
      () => GetMaterialApp(
        title: 'Flutter Ping',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeService.themeMode.value,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
