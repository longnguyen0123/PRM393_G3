import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.status,
  });

  final String id;
  final String name;
  final String? status; // 'ACTIVE' or 'INACTIVE'

  @override
  List<Object?> get props => [id, name, status];
}
