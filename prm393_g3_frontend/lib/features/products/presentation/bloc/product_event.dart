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

class ProductCreateRequested extends ProductEvent {
  const ProductCreateRequested({
    required this.name,
    required this.brandId,
    required this.categoryId,
    this.description,
    this.status,
  });

  final String name;
  final String brandId;
  final String categoryId;
  final String? description;
  final String? status;

  @override
  List<Object?> get props => [name, brandId, categoryId, description, status];
}

class ProductUpdateRequested extends ProductEvent {
  const ProductUpdateRequested({
    required this.id,
    this.name,
    this.brandId,
    this.categoryId,
    this.description,
    this.status,
  });

  final String id;
  final String? name;
  final String? brandId;
  final String? categoryId;
  final String? description;
  final String? status;

  @override
  List<Object?> get props => [id, name, brandId, categoryId, description, status];
}
