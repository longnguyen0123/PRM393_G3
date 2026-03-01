import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/branch_event.dart';
import '../bloc/branch_state.dart';
import '../../../../core/widgets/app_drawer.dart';

class BranchListPage extends StatelessWidget {
  const BranchListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BranchBloc>()..add(BranchRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Branches'),
        ),
        drawer: const AppDrawer(),
        body: BlocBuilder<BranchBloc, BranchState>(
          builder: (context, state) {
            if (state is BranchLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BranchLoaded) {
              if (state.branches.isEmpty) {
                return const Center(child: Text("No branches found"));
              }

              return ListView.builder(
                itemCount: state.branches.length,
                itemBuilder: (context, index) {
                  final branch = state.branches[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(branch.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          branch.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            if (state is BranchError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}