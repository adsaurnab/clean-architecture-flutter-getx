import '../../data/model/home_model.dart';

abstract class HomeRepository {
  Future<List<HomeModel>> getProducts();
}