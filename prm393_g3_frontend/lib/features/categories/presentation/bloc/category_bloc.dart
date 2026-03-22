import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/update_category.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.createCategory,
    required this.updateCategory,
  }) : super(const CategoryState.initial()) {
    on<CategoryRequested>(_onRequested);
    on<CategoryRefreshed>(_onRequested);
    on<CategoryCreateRequested>(_onCreate);
    on<CategoryUpdateRequested>(_onUpdate);
  }

  final GetCategoriesUseCase getCategoriesUseCase;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;

  Future<void> _onRequested(CategoryEvent event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await getCategoriesUseCase();
      emit(state.copyWith(status: CategoryStatus.success, categories: categories, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(CategoryCreateRequested event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      await createCategory(name: event.name, status: event.status);
      final categories = await getCategoriesUseCase();
      emit(state.copyWith(status: CategoryStatus.success, categories: categories, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdate(CategoryUpdateRequested event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      await updateCategory(id: event.id, name: event.name, status: event.status);
      final categories = await getCategoriesUseCase();
      emit(state.copyWith(status: CategoryStatus.success, categories: categories, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, errorMessage: e.toString()));
    }
  }
}
