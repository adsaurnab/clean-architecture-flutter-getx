import '../model/profile_model.dart';
import '../../domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  @override
  Future<ProfileModel> getProfile() async {

    await Future.delayed(
      const Duration(seconds: 1),
    );

    return ProfileModel(
      name: "John Doe",
      email: "john@example.com",
      phone: "+1 234 567890",
      image: "https://i.pravatar.cc/300",
    );
  }
}