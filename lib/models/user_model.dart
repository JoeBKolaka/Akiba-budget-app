import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String symbol;
  final String flag;
  final int decimal_digits;
  final String thousands_separator;
  final DateTime created_at;
  UserModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.decimal_digits,
    required this.thousands_separator,
    required this.created_at,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? symbol,
    String? flag,
    int? decimal_digits,
    String? thousands_separator,
    DateTime? created_at,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      flag: flag ?? this.flag,
      decimal_digits: decimal_digits ?? this.decimal_digits,
      thousands_separator: thousands_separator ?? this.thousands_separator,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'symbol': symbol,
      'flag': flag,
      'decimal_digits': decimal_digits,
      'thousands_separator': thousands_separator,
      'created_at': created_at.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      flag: map['flag'] as String,
      decimal_digits: map['decimal_digits'] as int,
      thousands_separator: map['thousands_separator'] as String,
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, symbol: $symbol, flag: $flag, decimal_digits: $decimal_digits, thousands_separator: $thousands_separator, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.symbol == symbol &&
      other.flag == flag &&
      other.decimal_digits == decimal_digits &&
      other.thousands_separator == thousands_separator &&
      other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      symbol.hashCode ^
      flag.hashCode ^
      decimal_digits.hashCode ^
      thousands_separator.hashCode ^
      created_at.hashCode;
  }
}