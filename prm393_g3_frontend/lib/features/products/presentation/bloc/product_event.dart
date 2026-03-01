part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductRequested extends ProductEvent {
  const ProductRequested({this.brandId, this.categoryId, this.searchQuery});

  final String? brandId;
  final String? categoryId;
  final String? searchQuery;

  @override
  List<Object?> get props => [brandId, categoryId, searchQuery];
}

class ProductRefreshed extends ProductEvent {
  const ProductRefreshed({this.brandId, this.categoryId, this.searchQuery});

  final String? brandId;
  final String? categoryId;
  final String? searchQuery;

  @override
  List<Object?> get props => [brandId, categoryId, searchQuery];
}

class ProductFilterChanged extends ProductEvent {
  const ProductFilterChanged({this.brandId, this.categoryId, this.searchQuery});

  final String? brandId;
  final String? categoryId;
  final String? searchQuery;

  @override
  List<Object?> get props => [brandId, categoryId, searchQuery];
}
