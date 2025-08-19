import 'package:get/get.dart';
import '../modules/home/home_page.dart';
import '../modules/home/home_controller.dart';

class AppPages {
  static const String initial = '/';
  
  static final routes = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
  ];
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}