import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import '../../modules/home/home_controller.dart';
import '../../data/services/theme_service.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final Color surface = Get.theme.colorScheme.surface;
    final Color onSurface = Get.theme.colorScheme.onSurface;
    final Color divider = Get.theme.dividerColor;
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Row(
        children: [
          // Left side - App title and drag area
          Expanded(
            child: MoveWindow(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icon.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Flutter Ping',
                      style: TextStyle(
                        color: onSurface.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      final ThemeService themeService =
                          Get.find<ThemeService>();
                      final ThemeMode mode = themeService.themeMode.value;
                      final Brightness brightness = Theme.of(
                        context,
                      ).brightness;
                      final bool isDark =
                          mode == ThemeMode.dark ||
                          (mode == ThemeMode.system &&
                              brightness == Brightness.dark);
                      return IconButton(
                        onPressed: themeService.toggleTheme,
                        icon: Icon(
                          isDark
                              ? Icons.wb_sunny_outlined
                              : Icons.nightlight_round,
                          size: 16,
                        ),
                        tooltip: isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                        style: IconButton.styleFrom(
                          foregroundColor: onSurface.withOpacity(0.7),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(4),
                        ),
                      );
                    }),
                    // Clear results button
                    GetBuilder<HomeController>(
                      builder: (controller) => IconButton(
                        onPressed: controller.isRunningChecks
                            ? null
                            : controller.clearResults,
                        icon: const Icon(Icons.clear_all, size: 16),
                        tooltip: 'Clear Results',
                        style: IconButton.styleFrom(
                          foregroundColor: onSurface.withOpacity(0.7),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right side - Window control buttons
          Row(
            children: [
              MinimizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: onSurface.withOpacity(0.7),
                  mouseOver: onSurface.withOpacity(0.85),
                  mouseDown: onSurface.withOpacity(0.5),
                  iconMouseOver: onSurface.withOpacity(0.6),
                  iconMouseDown: onSurface.withOpacity(0.55),
                ),
              ),
              MaximizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: onSurface.withOpacity(0.7),
                  mouseOver: onSurface.withOpacity(0.85),
                  mouseDown: onSurface.withOpacity(0.5),
                  iconMouseOver: onSurface.withOpacity(0.6),
                  iconMouseDown: onSurface.withOpacity(0.55),
                ),
              ),
              CloseWindowButton(
                colors: WindowButtonColors(
                  iconNormal: onSurface.withOpacity(0.7),
                  mouseOver: const Color(0xFFD32F2F),
                  mouseDown: const Color(0xFFB71C1C),
                  iconMouseOver: Colors.white,
                  iconMouseDown: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
