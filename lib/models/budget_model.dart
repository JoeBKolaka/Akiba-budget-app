// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BudgetModel {
  final String id;
  final String user_id;
  final String category_id;
  final double budget_amount;
  final String repetition;
  final DateTime created_at;
  BudgetModel({
    required this.id,
    required this.user_id,
    required this.category_id,
    required this.budget_amount,
    required this.repetition,
    required this.created_at,
  });

  BudgetModel copyWith({
    String? id,
    String? user_id,
    String? category_id,
    double? budget_amount,
    String? repetition,
    DateTime? created_at,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      category_id: category_id ?? this.category_id,
      budget_amount: budget_amount ?? this.budget_amount,
      repetition: repetition ?? this.repetition,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'category_id': category_id,
      'budget_amount': budget_amount,
      'repetition': repetition,
      'created_at': created_at.millisecondsSinceEpoch,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      user_id: map['user_id'] as String,
      category_id: map['category_id'] as String,
      budget_amount: map['budget_amount'] as double,
      repetition: map['repetition'] as String,
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory BudgetModel.fromJson(String source) =>
      BudgetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BudgetModel(id: $id, user_id: $user_id, category_id: $category_id, budget_amount: $budget_amount, repetition: $repetition, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant BudgetModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user_id == user_id &&
        other.category_id == category_id &&
        other.budget_amount == budget_amount &&
        other.repetition == repetition &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user_id.hashCode ^
        category_id.hashCode ^
        budget_amount.hashCode ^
        repetition.hashCode ^
        created_at.hashCode;
  }
}
