import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create-branch');
          },
          child: const Icon(Icons.add),
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
                            child: ListTile(
                              title: Text(branch.name),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(branch.address),
                                  const SizedBox(height: 4),
                                  Text("Stock: ${branch.totalItemsInStock}"),
                                ],
                              ),
                              trailing: Container(
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
                                  branch.status,
                                  style: const TextStyle(
                                      color: Colors.white),
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