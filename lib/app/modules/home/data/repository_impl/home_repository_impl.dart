import '../model/home_model.dart';
import '../../domain/repository/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {

  @override
  Future<List<HomeModel>> getProducts() async {

    await Future.delayed(
      const Duration(seconds: 1),
    );

    return [
      HomeModel(
        id: 1,
        title: "MacBook Pro",
        description: "Powerful laptop for developers",
        image:
            "https://picsum.photos/200",
      ),
      HomeModel(
        id: 2,
        title: "iPhone 16",
        description: "Latest Apple smartphone",
        image:
            "https://picsum.photos/201",
      ),
      HomeModel(
        id: 3,
        title: "iPad Air",
        description: "Portable productivity device",
        image:
            "https://picsum.photos/202",
      ),
    ];
  }
}