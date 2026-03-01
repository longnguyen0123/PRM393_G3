part of 'product_bloc.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  const ProductState({
    required this.status,
    required this.products,
    this.errorMessage,
    this.selectedBrandId,
    this.selectedCategoryId,
    this.searchQuery,
  });

  const ProductState.initial()
      : status = ProductStatus.initial,
        products = const [],
        errorMessage = null,
        selectedBrandId = null,
        selectedCategoryId = null,
        searchQuery = null;

  final ProductStatus status;
  final List<Product> products;
  final String? errorMessage;
  final String? selectedBrandId;
  final String? selectedCategoryId;
  final String? searchQuery;

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? errorMessage,
    String? selectedBrandId,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
      selectedBrandId: selectedBrandId ?? this.selectedBrandId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage, selectedBrandId, selectedCategoryId, searchQuery];
}
