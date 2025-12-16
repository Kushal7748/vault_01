// Re-export of the Secret model to keep previous import paths working.
export 'screen_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class SecretModel {
  final String id;
  final String title;
  final String value; // The password/secret
  final String? username;

  const SecretModel({
    required this.id,
    required this.title,
    required this.value,
    this.username,
  });

  SecretModel copyWith({
    String? id,
    String? title,
    String? value,
    String? username,
  }) {
    return SecretModel(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      username: username ?? this.username,
    );
  }
}
