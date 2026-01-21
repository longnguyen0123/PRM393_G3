import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({required this.getProductsUseCase}) : super(const ProductState.initial()) {
    on<ProductRequested>(_onRequested);
    on<ProductRefreshed>(_onRequested);
  }

  final GetProductsUseCase getProductsUseCase;

  Future<void> _onRequested(ProductEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await getProductsUseCase();
      emit(state.copyWith(status: ProductStatus.success, products: products));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
    }
  }
}
