part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryRequested extends CategoryEvent {
  const CategoryRequested();
}

class CategoryRefreshed extends CategoryEvent {
  const CategoryRefreshed();
}
