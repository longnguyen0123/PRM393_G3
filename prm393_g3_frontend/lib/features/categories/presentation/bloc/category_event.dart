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

class CategoryCreateRequested extends CategoryEvent {
  const CategoryCreateRequested({required this.name, this.status});

  final String name;
  final String? status;

  @override
  List<Object?> get props => [name, status];
}

class CategoryUpdateRequested extends CategoryEvent {
  const CategoryUpdateRequested({required this.id, this.name, this.status});

  final String id;
  final String? name;
  final String? status;

  @override
  List<Object?> get props => [id, name, status];
}
