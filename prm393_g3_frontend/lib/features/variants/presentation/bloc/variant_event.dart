part of 'variant_bloc.dart';

abstract class VariantEvent extends Equatable {
  const VariantEvent();

  @override
  List<Object?> get props => [];
}

class VariantRequested extends VariantEvent {
  const VariantRequested(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

class VariantRefreshed extends VariantEvent {
  const VariantRefreshed(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
