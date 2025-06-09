import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/category_repo.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepo repo;
  CategoryCubit(this.repo) : super(CategoryInitial());

  Future<void> fetchCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await repo.fetchCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
