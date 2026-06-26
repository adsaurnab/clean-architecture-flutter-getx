import 'package:get/get.dart';
import '../../data/model/profile_model.dart';
import '../../domain/repository/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository repository = Get.find<ProfileRepository>();

  final RxBool isLoading = false.obs;

  final Rx<ProfileModel?> profile = Rxn<ProfileModel>();
  final Rx<String?> error = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    error.value = null;

    try {
      profile.value = await repository.getProfile();
    } catch (e) {
      error.value = 'Could not load profile. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
