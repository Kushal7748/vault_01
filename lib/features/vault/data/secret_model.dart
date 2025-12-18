import 'dart:convert';

class SecretModel {
  final String id;
  final String title;
  final String username;
  final String value;

  SecretModel({
    required this.id,
    required this.title,
    required this.username,
    required this.value,
  });

  // 1. CopyWith: Essential for editing immutable objects
  SecretModel copyWith({
    String? id,
    String? title,
    String? username,
    String? value,
  }) {
    return SecretModel(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      value: value ?? this.value,
    );
  }

  // 2. ToMap: Convert Object -> Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'value': value,
    };
  }

  // 3. FromMap: Convert Map -> Object
  factory SecretModel.fromMap(Map<String, dynamic> map) {
    return SecretModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      username: map['username'] ?? '',
      value: map['value'] ?? '',
    );
  }

  // 4. ToJson: Convert Map -> String (For Storage)
  String toJson() => json.encode(toMap());

  // 5. FromJson: Convert String -> Map (From Storage)
  factory SecretModel.fromJson(String source) =>
      SecretModel.fromMap(json.decode(source));
}
