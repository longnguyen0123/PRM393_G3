import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/branch.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/branch_event.dart';
import '../bloc/branch_state.dart';

class CreateBranchPage extends StatefulWidget {
  const CreateBranchPage({super.key});

  @override
  State<CreateBranchPage> createState() => _CreateBranchPageState();
}

class _CreateBranchPageState extends State<CreateBranchPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String _status = "ACTIVE";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BranchBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Branch"),
        ),
        body: BlocConsumer<BranchBloc, BranchState>(
          listener: (context, state) {
            if (state is BranchLoaded) {
              Navigator.pushReplacementNamed(context, '/branch-list');
            }

            if (state is BranchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [

                        // Branch Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Branch Name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Branch name is required";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: "Address",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Address is required";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: "Status",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "ACTIVE",
                              child: Text("Active"),
                            ),
                            DropdownMenuItem(
                              value: "INACTIVE",
                              child: Text("Inactive"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _status = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final branch = Branch(
                                  id: '',
                                  name: _nameController.text.trim(),
                                  address: _addressController.text.trim(),
                                  status: _status,
                                  totalItemsInStock: 0,
                                );

                                context.read<BranchBloc>().add(
                                      BranchCreateRequested(branch),
                                    );
                              }
                            },
                            child: const Text("Create Branch"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading Overlay
                if (state is BranchLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}