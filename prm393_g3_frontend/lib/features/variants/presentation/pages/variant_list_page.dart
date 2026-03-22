import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/admin_only_page.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../bloc/variant_bloc.dart';
import '../../domain/entities/variant.dart';

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
            onPressed: () {
              // TODO: Implement add variant functionality
            },
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
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No variants found')),
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
                    ...state.variants.map((variant) => _buildVariantCard(variant)),
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

  Widget _buildVariantCard(Variant variant) {
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
          Text(
            variant.variantName ?? variant.sku,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
