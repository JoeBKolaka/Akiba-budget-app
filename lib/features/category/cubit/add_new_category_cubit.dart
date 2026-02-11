import 'package:akiba/models/category_model.dart';
import 'package:akiba/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../repository/category_local_repository.dart';

part 'add_new_category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryStateInitial());
  final categoryLocalRepository = CategoryLocalRepository();
  final Uuid uuid = Uuid();

  Future<void> createNewCategory({
    required String name,
    required String emoji,
    required Color color,
    required String user_id,
  }) async {
    try {
      final categoryModel = CategoryModel(
        id: uuid.v4(),
        user_id: user_id,
        name: name,
        emoji: emoji,
        hex_color: rgbToHex(color),
        created_at: DateTime.now(),
      );
      await categoryLocalRepository.insertCategory(
        categoryModel,
        user_id: user_id,
      );
      emit(CategoryStateAdd(categoryModel));
    } catch (e) {
      emit(CategoryStateError('Failed to save: $e '));
    }
  }

  
  Future<void> updateCategory({
    required String id,
    required String name,
    required String emoji,
    required Color color,
    required String user_id,
  }) async {
    try {
      await categoryLocalRepository.updateCategory(
        id: id,
        name: name,
        emoji: emoji,
        hex_color: rgbToHex(color),
        user_id: user_id,
      );
      emit(CategoryStateUpdate());
    } catch (e) {
      emit(CategoryStateError(e.toString()));
    }
  }
}
