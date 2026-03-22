import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../bloc/category_bloc.dart';
import '../../../brands/presentation/bloc/brand_bloc.dart';
import '../../../brands/domain/entities/brand.dart';
import '../../domain/entities/category.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
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
          'Product Categories',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => getIt<BrandBloc>()..add(const BrandRequested()),
          ),
          BlocProvider(
            create: (context) => getIt<CategoryBloc>()..add(const CategoryRequested()),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<BrandBloc, BrandState>(
              listenWhen: (p, c) => c.status == BrandStatus.failure,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? 'Brand error')),
                );
              },
            ),
            BlocListener<CategoryBloc, CategoryState>(
              listenWhen: (p, c) => c.status == CategoryStatus.failure,
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? 'Category error')),
                );
              },
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildBrandsSection(context),
                const SizedBox(height: 16),
                _buildCategoriesSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Brands',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                onPressed: () => _showBrandDialog(context),
                tooltip: 'Add brand',
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<BrandBloc, BrandState>(
            builder: (context, state) {
              if (state.status == BrandStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == BrandStatus.failure) {
                return Text('Error: ${state.errorMessage}');
              }
              if (state.brands.isEmpty) {
                return const Text('No brands found');
              }
              return Column(
                children: state.brands
                    .map<Widget>((Brand brand) => _brandTile(context, brand))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _brandTile(BuildContext context, Brand brand) {
    return InkWell(
      onTap: () => _showBrandDialog(context, brand: brand),
      child: _buildListItem(brand.name, brand.status ?? 'ACTIVE'),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                onPressed: () => _showCategoryDialog(context),
                tooltip: 'Add category',
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state.status == CategoryStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == CategoryStatus.failure) {
                return Text('Error: ${state.errorMessage}');
              }
              if (state.categories.isEmpty) {
                return const Text('No categories found');
              }
              return Column(
                children: state.categories
                    .map<Widget>((Category category) => _categoryTile(context, category))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(BuildContext context, Category category) {
    return InkWell(
      onTap: () => _showCategoryDialog(context, category: category),
      child: _buildListItem(category.name, category.status ?? 'ACTIVE'),
    );
  }

  void _showBrandDialog(BuildContext context, {Brand? brand}) {
    final bloc = context.read<BrandBloc>();
    final nameCtrl = TextEditingController(text: brand?.name ?? '');
    String status = brand?.status ?? 'ACTIVE';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(brand == null ? 'New brand' : 'Edit brand'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                        DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                      ],
                      onChanged: (v) {
                        setLocalState(() {
                          status = v ?? 'ACTIVE';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      return;
                    }
                    if (brand == null) {
                      bloc.add(BrandCreateRequested(name: name, status: status));
                    } else {
                      bloc.add(BrandUpdateRequested(id: brand.id, name: name, status: status));
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final bloc = context.read<CategoryBloc>();
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    String status = category?.status ?? 'ACTIVE';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(category == null ? 'New category' : 'Edit category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                        DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                      ],
                      onChanged: (v) {
                        setLocalState(() {
                          status = v ?? 'ACTIVE';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      return;
                    }
                    if (category == null) {
                      bloc.add(CategoryCreateRequested(name: name, status: status));
                    } else {
                      bloc.add(CategoryUpdateRequested(id: category.id, name: name, status: status));
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildListItem(String name, String status) {
    final isActive = status == 'ACTIVE';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
