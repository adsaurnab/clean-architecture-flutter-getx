import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../domain/repository/profile_repository.dart';
import '../../data/repository_impl/profile_repository_impl.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl());

    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
