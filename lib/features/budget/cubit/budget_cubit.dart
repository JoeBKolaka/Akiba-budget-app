import 'package:akiba/models/budget_model.dart';
import 'package:akiba/models/category_model.dart';
import 'package:akiba/repository/budget_local_repository.dart';
import 'package:akiba/repository/category_local_repository.dart';
import 'package:akiba/repository/transaction_local_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit() : super(BudgetStateInitial());
  final budgetLocalRepository = BudgetLocalRepository();
  final categoryLocalRepository = CategoryLocalRepository();
  final transactionLocalRepository = TransactionLocalRepository();
  final Uuid uuid = Uuid();

  Future<void> createNewBudget({
    required String category_id,
    required String user_id,
    required String repetition,
    required double budget_amount,
  }) async {
    try {
      final budgetModel = BudgetModel(
        id: uuid.v4(),
        user_id: user_id,
        category_id: category_id,
        budget_amount: budget_amount,
        repetition: repetition,
        created_at: DateTime.now(),
      );
      await budgetLocalRepository.insertBudget(
        budgetModel,
        user_id: user_id,
        category_id: category_id,
      );
      print(budgetModel);
      emit(BudgetStateAdd(budgetModel));
    } catch (e) {
      if (e.toString().contains('already exists')) {
        emit(BudgetStateError('Budget already exists for this category'));
      } else {
        emit(BudgetStateError('Failed to save'));
      }
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      return await categoryLocalRepository.getCategories();
    } catch (e) {
      emit(BudgetStateError(e.toString()));
      return [];
    }
  }

  Future<Map<String, double>> getBudgetSpending(String categoryId) async {
    try {
      final today = await transactionLocalRepository.getTodayExpensesByCategory(categoryId);
      final thisWeek = await transactionLocalRepository.getThisWeekExpensesByCategory(categoryId);
      final thisMonth = await transactionLocalRepository.getThisMonthExpensesByCategory(categoryId);
      final thisYear = await transactionLocalRepository.getThisYearExpensesByCategory(categoryId);
      
      return {
        'today': today,
        'week': thisWeek,
        'month': thisMonth,
        'year': thisYear,
      };
    } catch (e) {
      emit(BudgetStateError(e.toString()));
      return {'today': 0.0, 'week': 0.0, 'month': 0.0, 'year': 0.0};
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      final db = await budgetLocalRepository.database;
      await db.delete(
        'budgets',
        where: 'id = ?',
        whereArgs: [budgetId],
      );
      emit(BudgetStateDelete(budgetId));
    } catch (e) {
      emit(BudgetStateError(e.toString()));
    }
  }
}