part of 'category_bloc.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryState extends Equatable {
  const CategoryState({
    required this.status,
    required this.categories,
    this.errorMessage,
  });

  const CategoryState.initial()
      : status = CategoryStatus.initial,
        categories = const [],
        errorMessage = null;

  final CategoryStatus status;
  final List<Category> categories;
  final String? errorMessage;

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
