import 'package:flutter/material.dart';
import '../../features/products/domain/entities/product.dart';

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.status == 'ACTIVE' ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: product.status == 'ACTIVE' ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (product.brandName != null)
              Row(
                children: [
                  Icon(Icons.branding_watermark, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text('Brand: ${product.brandName}'),
                ],
              ),
            if (product.categoryName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text('Category: ${product.categoryName}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
