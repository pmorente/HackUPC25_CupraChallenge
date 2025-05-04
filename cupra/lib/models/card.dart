class CardModel {
  final String title;
  final String description;
  final String image;
  final String text;

  CardModel({
    required this.title,
    required this.description,
    required this.image,
    required this.text,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      text: json['text'] as String,
    );
  }
}
