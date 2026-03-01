import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prm393_g3_frontend/core/widgets/app_drawer.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retail Chain - Sản phẩm'),
        actions: [
          IconButton(
            onPressed: () => context.read<ProductBloc>().add(const ProductRefreshed()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProductStatus.failure:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Lỗi không xác định'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProductBloc>().add(const ProductRequested()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            case ProductStatus.success:
              if (state.products.isEmpty) {
                return const Center(child: Text('Chưa có sản phẩm'));
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<ProductBloc>().add(const ProductRefreshed()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProductCard(product: product),
                    );
                  },
                ),
              );
            case ProductStatus.initial:
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
