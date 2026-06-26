  class HomeModel {
  final int id;
  final String title;
  final String description;
  final String image;

  HomeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
    };
  }
}