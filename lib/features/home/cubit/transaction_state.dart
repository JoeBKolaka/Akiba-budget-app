part of 'transaction_cubit.dart';

sealed class TransactionState {
  const TransactionState();
}

final class TransactionStateInitial extends TransactionState {}

final class TransactionStateLoading extends TransactionState {}

final class TransactionStateError extends TransactionState {
  final String error;

  const TransactionStateError(this.error);
}

final class TransactionStateLoaded extends TransactionState {
  final List<TransactionModel> transactions;

  const TransactionStateLoaded(this.transactions);
}