import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.storeId,
  });

  final String id;
  final String name;
  final num price;
  final int stock;
  final String storeId;

  @override
  List<Object?> get props => [id, name, price, stock, storeId];
}
