
import 'dart:convert';
import 'dart:ui';

import 'package:akiba/utils/utils.dart';

class CategoryModel {
  final String id;
  final String user_id;
  final String name;
  final String emoji;
  final String hex_color;  
  final DateTime created_at;
  
  
  Color get color => hexToRgb(hex_color);
  
  CategoryModel({
    required this.id,
    required this.user_id,
    required this.name,
    required this.emoji,
    required this.hex_color,  
    required this.created_at,
  });

  CategoryModel copyWith({
    String? id,
    String? user_id,
    String? name,
    String? emoji,
    String? hex_color,  // Keep as String
    DateTime? created_at,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      hex_color: hex_color ?? this.hex_color,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'name': name,
      'emoji': emoji,
      'hex_color': hex_color,  // Already a string
      'created_at': created_at.millisecondsSinceEpoch,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      user_id: map['user_id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      hex_color: map['hex_color'] as String,  // Already a string
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CategoryModel(id: $id, user_id: $user_id, name: $name, emoji: $emoji, hex_color: $hex_color, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant CategoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user_id == user_id &&
        other.name == name &&
        other.emoji == emoji &&
        other.hex_color == hex_color &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user_id.hashCode ^
        name.hashCode ^
        emoji.hashCode ^
        hex_color.hashCode ^
        created_at.hashCode;
  }
}