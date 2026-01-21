import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${product.price.toStringAsFixed(0)} đ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text('Store #${product.storeId}'),
                const Spacer(),
                Chip(
                  label: Text('Tồn: ${product.stock}'),
                  backgroundColor: Colors.green.shade50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
