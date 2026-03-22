import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../domain/entities/branch.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/branch_event.dart';
import '../bloc/branch_state.dart';

class EditBranchPage extends StatefulWidget {
  const EditBranchPage({
    super.key,
    required this.branch,
  });

  final Branch branch;

  @override
  State<EditBranchPage> createState() => _EditBranchPageState();
}

class _EditBranchPageState extends State<EditBranchPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late String _status;
  late bool _inventoryDelegatedToManager;
  String? _pendingAction;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch.name);
    _addressController = TextEditingController(text: widget.branch.address);
    _status = widget.branch.status;
    _inventoryDelegatedToManager = widget.branch.inventoryDelegatedToManager;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BranchBloc>(),
      child: BlocConsumer<BranchBloc, BranchState>(
        listener: (context, state) {
          if (state is BranchLoaded) {
            Navigator.of(context).pop(_pendingAction);
          }

          if (state is BranchError) {
            _pendingAction = null;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is BranchLoading;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: const Text('Edit Branch'),
              actions: [
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final branchBloc = context.read<BranchBloc>();
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete Branch'),
                              content: Text(
                                'Are you sure you want to delete ${widget.branch.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(true);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true && mounted) {
                            _pendingAction = 'deleted';
                            branchBloc.add(
                                  BranchDeleteRequested(widget.branch.id),
                                );
                          }
                        },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Branch',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.account_circle_outlined),
                ),
              ],
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 0),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Branch Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Branch name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Address is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Branch Status',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'ACTIVE',
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'INACTIVE',
                                    child: Text('Inactive'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _status = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Giao quản lý kho cho Branch Manager'),
                                subtitle: const Text(
                                  'Khi bật, Branch Manager được phép thêm / vô hiệu hóa nhân viên kho tại chi nhánh này.',
                                ),
                                value: _inventoryDelegatedToManager,
                                onChanged: (v) {
                                  setState(() {
                                    _inventoryDelegatedToManager = v;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final updatedBranch = Branch(
                                        id: widget.branch.id,
                                        name: _nameController.text.trim(),
                                        address: _addressController.text.trim(),
                                        status: _status,
                                        totalItemsInStock:
                                            widget.branch.totalItemsInStock,
                                        inventoryDelegatedToManager:
                                            _inventoryDelegatedToManager,
                                      );

                                      _pendingAction = 'updated';
                                      context.read<BranchBloc>().add(
                                            BranchUpdateRequested(updatedBranch),
                                          );
                                    }
                                  },
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}