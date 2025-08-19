import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/home/home_page.dart';
import '../modules/home/home_controller.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(HomeController());
    
    return const HomePage();
  }
}