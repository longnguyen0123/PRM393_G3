import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../domain/entities/branch.dart';
import 'branch_detail_page.dart';
import 'edit_branch_page.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/branch_event.dart';
import '../bloc/branch_state.dart';

class BranchListPage extends StatefulWidget {
  const BranchListPage({super.key});

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _handleActionResult(BuildContext pageContext, dynamic result) {
    final action = result is String ? result : null;
    if (action == null) {
      return;
    }

    pageContext.read<BranchBloc>().add(BranchRequested());

    final message = switch (action) {
      'created' => 'Branch created successfully',
      'updated' => 'Branch updated successfully',
      _ => null,
    };

    if (message != null) {
      ScaffoldMessenger.of(pageContext)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  Future<void> _openEditBranch(BuildContext pageContext, Branch branch) async {
    final result = await Navigator.of(pageContext).push(
      MaterialPageRoute(
        builder: (_) => EditBranchPage(branch: branch),
      ),
    );
    if (pageContext.mounted) {
      _handleActionResult(pageContext, result);
    }
  }

  Future<void> _openCreateBranch(BuildContext pageContext) async {
    final result = await Navigator.pushNamed(pageContext, '/create-branch');
    if (pageContext.mounted) {
      _handleActionResult(pageContext, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BranchBloc>()..add(BranchRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Branches'),
        ),
        drawer: const AppDrawer(),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),

        // ADD CREATE BUTTON
        floatingActionButton: Builder(
          builder: (pageContext) => FloatingActionButton(
            onPressed: () => _openCreateBranch(pageContext),
            child: const Icon(Icons.add),
          ),
        ),

        body: Column(
          children: [

            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search branches...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // 📋 LIST
            Expanded(
              child: BlocBuilder<BranchBloc, BranchState>(
                builder: (context, state) {

                  if (state is BranchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BranchLoaded) {

                    final filteredBranches = state.branches.where((branch) {
                      return branch.name.toLowerCase().contains(_searchQuery) ||
                             branch.address.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredBranches.isEmpty) {
                      return const Center(child: Text("No branches found"));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<BranchBloc>().add(BranchRequested());
                      },
                      child: ListView.builder(
                        itemCount: filteredBranches.length,
                        itemBuilder: (context, index) {
                          final branch = filteredBranches[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BranchDetailPage(
                                      branchId: branch.id,
                                      titleFallback: branch.name,
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                if (result == 'updated') {
                                  context.read<BranchBloc>().add(BranchRequested());
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            branch.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _openEditBranch(context, branch),
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                      ],
                                    ),
                                    Text(branch.address),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: branch.status == "ACTIVE"
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            branch.status == 'ACTIVE'
                                                ? 'Active'
                                                : 'Inactive',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Total items in stock: ${branch.totalItemsInStock}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (state is BranchError) {
                    return Center(child: Text(state.message));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}