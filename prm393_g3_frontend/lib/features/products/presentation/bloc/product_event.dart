part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductRequested extends ProductEvent {
  const ProductRequested();
}

class ProductRefreshed extends ProductEvent {
  const ProductRefreshed();
}
