// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TransactionModel {
  final String id;
  final String user_id;
  final String category_id;
  final String account_id;
  final double transaction_amount;
  final String transaction_type;
  final DateTime created_at;
  TransactionModel({
    required this.id,
    required this.user_id,
    required this.category_id,
    required this.account_id,
    required this.transaction_amount,
    required this.transaction_type,
    required this.created_at,
  });

  TransactionModel copyWith({
    String? id,
    String? user_id,
    String? category_id,
    String? account_id,
    double? transaction_amount,
    String? transaction_type,
    DateTime? created_at,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      category_id: category_id ?? this.category_id,
      account_id: account_id ?? this.account_id,
      transaction_amount: transaction_amount ?? this.transaction_amount,
      transaction_type: transaction_type ?? this.transaction_type,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'category_id': category_id,
      'account_id': account_id,
      'transaction_amount': transaction_amount,
      'transaction_type': transaction_type,
      'created_at': created_at.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      user_id: map['user_id'] as String,
      category_id: map['category_id'] as String,
      account_id: map['account_id'] as String,
      transaction_amount: map['transaction_amount'] as double,
      transaction_type: map['transaction_type'] as String,
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TransactionModel(id: $id, user_id: $user_id, category_id: $category_id, account_id: $account_id, transaction_amount: $transaction_amount, transaction_type: $transaction_type, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant TransactionModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.user_id == user_id &&
      other.category_id == category_id &&
      other.account_id == account_id &&
      other.transaction_amount == transaction_amount &&
      other.transaction_type == transaction_type &&
      other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      user_id.hashCode ^
      category_id.hashCode ^
      account_id.hashCode ^
      transaction_amount.hashCode ^
      transaction_type.hashCode ^
      created_at.hashCode;
  }
}
