part of 'add_new_category_cubit.dart';

sealed class CategoryState {
  const CategoryState();
}

final class CategoryStateInitial extends CategoryState {}

final class CategoryStateError extends CategoryState {
  final String error;

  CategoryStateError(this.error);
}

final class CategoryStateAdd extends CategoryState {
  final CategoryModel categoryModel;

  const CategoryStateAdd(this.categoryModel);
}

final class CategoryStateGet extends CategoryState {
  final List<CategoryModel> categories;

  const CategoryStateGet(this.categories);
}
final class CategoryStateUpdate extends CategoryState {}
//final class CategoryStateInitial extends CategoryState {}
