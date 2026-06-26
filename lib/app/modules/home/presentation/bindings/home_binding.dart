import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../domain/repository/home_repository.dart';
import '../../data/repository_impl/home_repository_impl.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepositoryImpl());

    Get.lazyPut<HomeController>(() => HomeController());
  }
}
