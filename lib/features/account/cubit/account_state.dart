part of 'account_cubit.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountStateAdd extends AccountState {
  final AccountModel account;
  AccountStateAdd(this.account);
}

class AccountStateLoaded extends AccountState {
  final List<AccountModel> accounts;
  AccountStateLoaded(this.accounts);
}

class AccountStateError extends AccountState {
  final String message;
  AccountStateError(this.message);
}