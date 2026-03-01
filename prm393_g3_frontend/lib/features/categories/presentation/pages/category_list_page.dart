import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../bloc/category_bloc.dart';
import '../../../brands/presentation/bloc/brand_bloc.dart';
import '../../../brands/domain/entities/brand.dart';
import '../../domain/entities/category.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

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
    );
  }

  Widget _buildBrandsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Brands',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                children: state.brands.map((brand) => _buildListItem(brand.name, brand.status ?? 'ACTIVE')).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                children: state.categories.map((category) => _buildListItem(category.name, category.status ?? 'ACTIVE')).toList(),
              );
            },
          ),
        ],
      ),
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
