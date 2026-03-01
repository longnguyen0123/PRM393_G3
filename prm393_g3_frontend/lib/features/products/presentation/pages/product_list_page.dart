import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../bloc/product_bloc.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../categories/presentation/pages/category_list_page.dart';
import '../../../brands/presentation/bloc/brand_bloc.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../brands/domain/entities/brand.dart';
import '../../../categories/domain/entities/category.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBrandId;
  String? _selectedCategoryId;


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // TODO: Implement add product functionality
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProductBloc>()),
          BlocProvider.value(value: getIt<BrandBloc>()..add(const BrandRequested())),
          BlocProvider.value(value: getIt<CategoryBloc>()..add(const CategoryRequested())),
        ],
        child: Column(
          children: [
            _buildSearchAndFilters(context),
            Expanded(
              child: _buildProductList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search product model',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              context.read<ProductBloc>().add(ProductFilterChanged(
                    brandId: _selectedBrandId,
                    categoryId: _selectedCategoryId,
                    searchQuery: value.isEmpty ? null : value,
                  ));
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BlocBuilder<BrandBloc, BrandState>(
                  builder: (context, brandState) {
                    // Show loading or empty state if brands not loaded yet
                    if (brandState.brands.isEmpty && brandState.status.toString().contains('loading')) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: const Text('Loading brands...'),
                      );
                    }
                    return _buildFilterDropdown(
                      context,
                      'Brand',
                      _selectedBrandId,
                      brandState.brands,
                      (brand) => brand.id,
                      (brand) => brand.name,
                      (value) {
                        setState(() {
                          _selectedBrandId = value;
                        });
                        context.read<ProductBloc>().add(ProductFilterChanged(
                              brandId: value,
                              categoryId: _selectedCategoryId,
                              searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
                            ));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, categoryState) {
                    // Show loading or empty state if categories not loaded yet
                    if (categoryState.categories.isEmpty && categoryState.status.toString().contains('loading')) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: const Text('Loading categories...'),
                      );
                    }
                    return _buildFilterDropdown(
                      context,
                      'Category',
                      _selectedCategoryId,
                      categoryState.categories,
                      (category) => category.id,
                      (category) => category.name,
                      (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                        context.read<ProductBloc>().add(ProductFilterChanged(
                              brandId: _selectedBrandId,
                              categoryId: value,
                              searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
                            ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>(
    BuildContext context,
    String label,
    String? selectedId,
    List<T> items,
    String Function(T) getId,
    String Function(T) getName,
    Function(String?) onChanged,
  ) {
    // Build dropdown items
    final dropdownItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: null,
        child: Text('All $label'),
      ),
      ...items.map((item) {
        final id = getId(item);
        return DropdownMenuItem<String>(
          value: id,
          child: Text(getName(item)),
        );
      }),
    ];

    // Check if selectedId exists in items, if not, set to null to avoid assertion error
    final validSelectedId = selectedId != null &&
            items.any((item) => getId(item) == selectedId)
        ? selectedId
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validSelectedId,
          hint: Text(label),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: dropdownItems,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        switch (state.status) {
          case ProductStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ProductStatus.failure:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Error loading products'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.read<ProductBloc>().add(const ProductRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          case ProductStatus.success:
            if (state.products.isEmpty) {
              return const Center(child: Text('No products found'));
            }
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product List',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProductBloc>().add(ProductRefreshed(
                              brandId: _selectedBrandId,
                              categoryId: _selectedCategoryId,
                              searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
                            ));
                      },
                      child: ListView.builder(
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
                                ),
                              );
                            },
                            child: Container(
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
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
                                    Text(
                                      'Brand: ${product.brandName}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                  if (product.categoryName != null)
                                    Text(
                                      'Category: ${product.categoryName}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          case ProductStatus.initial:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

