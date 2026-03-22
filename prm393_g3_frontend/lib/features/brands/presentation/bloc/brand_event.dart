part of 'brand_bloc.dart';

abstract class BrandEvent extends Equatable {
  const BrandEvent();

  @override
  List<Object?> get props => [];
}

class BrandRequested extends BrandEvent {
  const BrandRequested();
}

class BrandRefreshed extends BrandEvent {
  const BrandRefreshed();
}

class BrandCreateRequested extends BrandEvent {
  const BrandCreateRequested({required this.name, this.status});

  final String name;
  final String? status;

  @override
  List<Object?> get props => [name, status];
}

class BrandUpdateRequested extends BrandEvent {
  const BrandUpdateRequested({required this.id, this.name, this.status});

  final String id;
  final String? name;
  final String? status;

  @override
  List<Object?> get props => [id, name, status];
}
