import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../bloc/variant_bloc.dart';
import '../../domain/entities/variant.dart';

class VariantListPage extends StatelessWidget {
  const VariantListPage({super.key, required this.productId, required this.productName});

  final String productId;
  final String productName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Variants',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
                return const Center(child: Text('No variants found'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<VariantBloc>().add(VariantRefreshed(productId));
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Variant List',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.variants.length,
                          itemBuilder: (context, index) {
                            final variant = state.variants[index];
                            return _buildVariantCard(variant);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case VariantStatus.initial:
            default:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildVariantCard(Variant variant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
