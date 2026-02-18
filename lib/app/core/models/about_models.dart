// Model classes for About page API response.

class AboutValue {
  final String title;
  final String description;

  AboutValue({
    required this.title,
    required this.description,
  });

  factory AboutValue.fromJson(Map<String, dynamic> json) {
    return AboutValue(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class AboutData {
  final String? image;
  final String? mission;
  final String? vision;
  final List<AboutValue> values;

  AboutData({
    this.image,
    this.mission,
    this.vision,
    required this.values,
  });

  factory AboutData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AboutData(values: []);
    }

    final valuesRaw = json['values'];
    List<AboutValue> valuesList = [];
    if (valuesRaw is List) {
      valuesList = valuesRaw
          .whereType<Map>()
          .map((e) => AboutValue.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return AboutData(
      image: json['image']?.toString(),
      mission: json['mission']?.toString(),
      vision: json['vision']?.toString(),
      values: valuesList,
    );
  }
}
