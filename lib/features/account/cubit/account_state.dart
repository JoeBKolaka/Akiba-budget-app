part of 'account_cubit.dart';

sealed class AccountState {
  AccountState();
}

final class AccountInitial extends AccountState {}

final class AccountStateError extends AccountState {
  final String error;

  AccountStateError(this.error);
}

final class AccountStateAdd extends AccountState {
  final AccountModel accountModel;

  AccountStateAdd(this.accountModel);
}