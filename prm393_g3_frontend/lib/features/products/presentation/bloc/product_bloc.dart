import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({required this.repository}) : super(const ProductState.initial()) {
    on<ProductRequested>(_onRequested);
    on<ProductRefreshed>(_onRequested);
    on<ProductFilterChanged>(_onFilterChanged);
  }

  final ProductRepository repository;

  Future<void> _onRequested(ProductEvent event, Emitter<ProductState> emit) async {
    final brandId = event is ProductRequested ? event.brandId : (event as ProductRefreshed).brandId;
    final categoryId = event is ProductRequested ? event.categoryId : (event as ProductRefreshed).categoryId;
    final searchQuery = event is ProductRequested ? event.searchQuery : (event as ProductRefreshed).searchQuery;

    emit(state.copyWith(status: ProductStatus.loading));
    try {
      // Call repository with all filters at once - backend will handle the combination
      final products = await repository.getProducts(
        brandId: brandId,
        categoryId: categoryId,
        search: searchQuery,
      );

      emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
        selectedBrandId: brandId,
        selectedCategoryId: categoryId,
        searchQuery: searchQuery,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterChanged(ProductFilterChanged event, Emitter<ProductState> emit) async {
    add(ProductRequested(
      brandId: event.brandId,
      categoryId: event.categoryId,
      searchQuery: event.searchQuery,
    ));
  }
}
