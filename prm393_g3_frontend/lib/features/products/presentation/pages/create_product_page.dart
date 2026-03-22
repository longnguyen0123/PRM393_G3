import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/admin_only_page.dart';
import '../../../brands/domain/entities/brand.dart';
import '../../../brands/presentation/bloc/brand_bloc.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../bloc/product_bloc.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _brandId;
  String? _categoryId;
  String _status = 'ACTIVE';
  bool _awaitingMutation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminOnlyPage(
      title: 'Tạo sản phẩm',
      child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ProductBloc>()),
        BlocProvider(create: (_) => getIt<BrandBloc>()..add(const BrandRequested())),
        BlocProvider(create: (_) => getIt<CategoryBloc>()..add(const CategoryRequested())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create product'),
        ),
        body: BlocConsumer<ProductBloc, ProductState>(
          listenWhen: (previous, current) {
            if (!_awaitingMutation) {
              return false;
            }
            return (previous.status == ProductStatus.loading && current.status == ProductStatus.success) ||
                current.status == ProductStatus.failure;
          },
          listener: (context, state) {
            if (!_awaitingMutation) {
              return;
            }
            if (state.status == ProductStatus.success && Navigator.of(context).canPop()) {
              setState(() => _awaitingMutation = false);
              Navigator.of(context).pop('created');
              return;
            }
            if (state.status == ProductStatus.failure) {
              setState(() => _awaitingMutation = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Failed to create product')),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Model name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<BrandBloc, BrandState>(
                          builder: (context, brandState) {
                            if (brandState.brands.isEmpty && brandState.status == BrandStatus.loading) {
                              return const LinearProgressIndicator();
                            }
                            final List<Brand> items = brandState.brands;
                            return DropdownButtonFormField<String>(
                              value: _brandId != null && items.any((b) => b.id == _brandId)
                                  ? _brandId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Brand',
                                border: OutlineInputBorder(),
                              ),
                              items: items
                                  .map(
                                    (Brand b) => DropdownMenuItem<String>(value: b.id, child: Text(b.name)),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _brandId = v),
                              validator: (v) => v == null || v.isEmpty ? 'Choose a brand' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, catState) {
                            if (catState.categories.isEmpty && catState.status == CategoryStatus.loading) {
                              return const LinearProgressIndicator();
                            }
                            final List<Category> items = catState.categories;
                            return DropdownButtonFormField<String>(
                              value: _categoryId != null && items.any((c) => c.id == _categoryId)
                                  ? _categoryId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: items
                                  .map(
                                    (Category c) =>
                                        DropdownMenuItem<String>(value: c.id, child: Text(c.name)),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _categoryId = v),
                              validator: (v) => v == null || v.isEmpty ? 'Choose a category' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                            DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                          ],
                          onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: state.status == ProductStatus.loading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() != true) {
                                    return;
                                  }
                                  setState(() => _awaitingMutation = true);
                                  context.read<ProductBloc>().add(
                                        ProductCreateRequested(
                                          name: _nameController.text.trim(),
                                          brandId: _brandId!,
                                          categoryId: _categoryId!,
                                          description: _descriptionController.text.trim().isEmpty
                                              ? null
                                              : _descriptionController.text.trim(),
                                          status: _status,
                                        ),
                                      );
                                },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.status == ProductStatus.loading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }
}
