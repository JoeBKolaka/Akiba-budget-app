part of 'currency_cubit.dart';

sealed class CurrencyState {}

final class CurrencyInitial extends CurrencyState {}

final class CurrencyPicked extends CurrencyState {
  final UserModel user;
  CurrencyPicked(this.user);
}

final class CurrencyPick extends CurrencyState {
  
}

final class CurrencyError extends CurrencyState {
  final String error;
  CurrencyError(this.error);
}
