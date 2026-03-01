import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories_usecase.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({required this.getCategoriesUseCase}) : super(const CategoryState.initial()) {
    on<CategoryRequested>(_onRequested);
    on<CategoryRefreshed>(_onRequested);
  }

  final GetCategoriesUseCase getCategoriesUseCase;

  Future<void> _onRequested(CategoryEvent event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await getCategoriesUseCase();
      emit(state.copyWith(status: CategoryStatus.success, categories: categories));
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, errorMessage: e.toString()));
    }
  }
}
