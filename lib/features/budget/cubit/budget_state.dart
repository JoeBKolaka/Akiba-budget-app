part of 'budget_cubit.dart';

sealed class BudgetState {}

final class BudgetStateInitial extends BudgetState {}

final class BudgetStateAdd extends BudgetState {
  final BudgetModel budget;

  BudgetStateAdd(this.budget);
}

final class BudgetStateDelete extends BudgetState {
  final String budgetId;

  BudgetStateDelete(this.budgetId);
}

final class BudgetStateError extends BudgetState {
  final String error;

  BudgetStateError(this.error);
}
