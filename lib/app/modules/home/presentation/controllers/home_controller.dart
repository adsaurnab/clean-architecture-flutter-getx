import 'package:get/get.dart';
import '../../data/model/home_model.dart';
import '../../domain/repository/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository repository = Get.find<HomeRepository>();

  final RxList<HomeModel> products = <HomeModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    error.value = null;

    try {
      products.value = await repository.getProducts();
    } catch (e) {
      error.value =
          'Could not load products. Check your connection and try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
