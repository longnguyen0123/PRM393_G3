import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  const Brand({
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
