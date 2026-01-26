// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AccountModel {
  final String id;
  final String user_id;
  final String account_name;
  final double ammount;
  final String account_type;
  final DateTime created_at;
  AccountModel({
    required this.id,
    required this.user_id,
    required this.account_name,
    required this.ammount,
    required this.account_type,
    required this.created_at,
  });

  AccountModel copyWith({
    String? id,
    String? user_id,
    String? account_name,
    double? ammount,
    String? account_type,
    DateTime? created_at,
  }) {
    return AccountModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      account_name: account_name ?? this.account_name,
      ammount: ammount ?? this.ammount,
      account_type: account_type ?? this.account_type,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'account_name': account_name,
      'ammount': ammount,
      'account_type': account_type,
      'created_at': created_at.millisecondsSinceEpoch,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      user_id: map['user_id'] as String,
      account_name: map['account_name'] as String,
      ammount: map['ammount'] as double,
      account_type: map['account_type'] as String,
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountModel.fromJson(String source) =>
      AccountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AccountModel(id: $id, user_id: $user_id, account_name: $account_name, ammount: $ammount, account_type: $account_type, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant AccountModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.user_id == user_id &&
      other.account_name == account_name &&
      other.ammount == ammount &&
      other.account_type == account_type &&
      other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      user_id.hashCode ^
      account_name.hashCode ^
      ammount.hashCode ^
      account_type.hashCode ^
      created_at.hashCode;
  }
}