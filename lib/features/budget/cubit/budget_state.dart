part of 'budget_cubit.dart';

sealed class BudgetState {
  const BudgetState();
}

final class BudgetStateInitial extends BudgetState {}

final class BudgetStateAdd extends BudgetState {
  final BudgetModel budgetModel;

  const BudgetStateAdd(this.budgetModel);
}

final class BudgetStateError extends BudgetState {
  final String error;

  BudgetStateError(this.error);
}

final class BudgetStateGet extends BudgetState {
  final List<BudgetModel> budgets;

  const BudgetStateGet(this.budgets);
}
