import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import '../../modules/home/home_controller.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        border: Border(bottom: BorderSide(color: Color(0xFF404040), width: 1)),
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
                        color: Colors.grey[300],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Clear results button
                    GetBuilder<HomeController>(
                      builder: (controller) => IconButton(
                        onPressed: controller.isRunningChecks
                            ? null
                            : controller.clearResults,
                        icon: const Icon(Icons.clear_all, size: 16),
                        tooltip: 'Clear Results',
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.grey[400],
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
                  iconNormal: Colors.grey[400]!,
                  mouseOver: Colors.grey[300]!,
                  mouseDown: Colors.grey[500]!,
                  iconMouseOver: Colors.grey[700]!,
                  iconMouseDown: Colors.grey[800]!,
                ),
              ),
              MaximizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: Colors.grey[400]!,
                  mouseOver: Colors.grey[300]!,
                  mouseDown: Colors.grey[500]!,
                  iconMouseOver: Colors.grey[700]!,
                  iconMouseDown: Colors.grey[800]!,
                ),
              ),
              CloseWindowButton(
                colors: WindowButtonColors(
                  iconNormal: Colors.grey[400]!,
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
