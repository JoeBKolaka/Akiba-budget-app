// states/transaction_state.dart
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

final class TransactionStateAdd extends TransactionState {
  final TransactionModel transactionModel;

  const TransactionStateAdd(this.transactionModel);
}

final class TransactionStateList extends TransactionState {
  final List<TransactionModel> transactions;

  const TransactionStateList(this.transactions);
}

final class TransactionStateInsufficientBalance extends TransactionState {
  final String accountId;
  final double currentBalance;
  final double requiredAmount;
  final String accountType;

  const TransactionStateInsufficientBalance({
    required this.accountId,
    required this.currentBalance,
    required this.requiredAmount,
    required this.accountType,
  });
}

final class TransactionStateSuccess extends TransactionState {
  final TransactionModel transaction;
  final String message;

  const TransactionStateSuccess({
    required this.transaction,
    this.message = 'Transaction completed successfully',
  });
}

final class TransactionStateUpdated extends TransactionState {
  final TransactionModel transaction;

  const TransactionStateUpdated(this.transaction);
}

final class TransactionStateDeleted extends TransactionState {
  final String transactionId;
  final String message;

  const TransactionStateDeleted({
    required this.transactionId,
    this.message = 'Transaction deleted successfully',
  });
}

final class TransactionStateSummary extends TransactionState {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const TransactionStateSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });
}

