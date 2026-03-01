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
