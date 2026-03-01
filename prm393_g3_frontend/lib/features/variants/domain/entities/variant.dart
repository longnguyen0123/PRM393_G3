import 'package:equatable/equatable.dart';

class Variant extends Equatable {
  const Variant({
    required this.id,
    required this.productId,
    required this.sku,
    this.barcode,
    required this.price,
    required this.status,
    this.variantName,
  });

  final String id;
  final String productId;
  final String sku;
  final String? barcode;
  final num price;
  final String status; // 'ACTIVE' or 'INACTIVE'
  final String? variantName;

  @override
  List<Object?> get props => [id, productId, sku, barcode, price, status, variantName];
}
