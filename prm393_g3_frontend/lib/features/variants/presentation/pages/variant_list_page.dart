import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/admin_only_page.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../bloc/variant_bloc.dart';
import '../../domain/entities/variant.dart';
import 'create_variant_page.dart';
import 'edit_variant_page.dart';

Future<void> _openCreateVariantForProduct(
  BuildContext context, {
  required String productId,
  required String productName,
}) async {
  final result = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => CreateVariantPage(
        productId: productId,
        productName: productName,
      ),
    ),
  );
  if (!context.mounted || result != 'created') {
    return;
  }
  context.read<VariantBloc>().add(VariantRefreshed(productId));
}

Future<void> _openEditVariantForProduct(
  BuildContext context, {
  required String productId,
  required String productName,
  required Variant variant,
}) async {
  final result = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => EditVariantPage(
        productName: productName,
        variant: variant,
      ),
    ),
  );
  if (!context.mounted || result != 'updated') {
    return;
  }
  context.read<VariantBloc>().add(VariantRefreshed(productId));
}

class VariantListPage extends StatelessWidget {
  const VariantListPage({super.key, required this.productId, required this.productName});

  final String productId;
  final String productName;

  @override
  Widget build(BuildContext context) {
    return AdminOnlyPage(
      title: 'Variants',
      child: Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Variants',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (productName.isNotEmpty)
              Text(
                productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _openCreateVariantForProduct(
              context,
              productId: productId,
              productName: productName,
            ),
          ),
        ],
      ),
      body: BlocBuilder<VariantBloc, VariantState>(
        builder: (context, state) {
          switch (state.status) {
            case VariantStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case VariantStatus.failure:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Error loading variants'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.read<VariantBloc>().add(VariantRequested(productId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case VariantStatus.success:
              if (state.variants.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<VariantBloc>().add(VariantRefreshed(productId));
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      const Center(child: Text('No variants found')),
                      const SizedBox(height: 16),
                      Center(
                        child: FilledButton.icon(
                          onPressed: () => _openCreateVariantForProduct(
                            context,
                            productId: productId,
                            productName: productName,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add variant'),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<VariantBloc>().add(VariantRefreshed(productId));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: const Text(
                        'Variant list',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    ...state.variants.map(
                      (variant) => _buildVariantCard(context, variant),
                    ),
                  ],
                ),
              );
            case VariantStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    ),
    );
  }

  Widget _buildVariantCard(BuildContext context, Variant variant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  variant.variantName ?? variant.sku,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black87),
                tooltip: 'Edit variant',
                onPressed: () => _openEditVariantForProduct(
                  context,
                  productId: productId,
                  productName: productName,
                  variant: variant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildVariantInfoRow('SKU:', variant.sku),
          if (variant.barcode != null) _buildVariantInfoRow('Barcode:', variant.barcode!),
          _buildVariantInfoRow('Price:', '\$${variant.price.toStringAsFixed(2)}', isPrice: true),
          if (variant.status.isNotEmpty)
            _buildVariantInfoRow('Status:', variant.status),
        ],
      ),
    );
  }

  Widget _buildVariantInfoRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
