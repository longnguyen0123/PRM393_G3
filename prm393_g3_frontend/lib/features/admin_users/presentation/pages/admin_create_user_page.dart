import 'package:flutter/material.dart';

import '../../../../core/widgets/admin_only_page.dart';
import '../../../../core/di/service_locator.dart';
import '../../../branches/data/datasources/branch_remote_datasource.dart';
import '../../../branches/data/models/branch_model.dart';
import '../../data/admin_user_remote_datasource.dart';

const _kRoles = <String>[
  'ADMIN',
  'BRANCH_MANAGER',
  'CASHIER',
  'INVENTORY_STAFF',
];

String _roleLabel(String r) {
  switch (r) {
    case 'ADMIN':
      return 'Quản trị viên (ADMIN)';
    case 'BRANCH_MANAGER':
      return 'Quản lý chi nhánh';
    case 'CASHIER':
      return 'Thu ngân';
    default:
      return r;
  }
}

class AdminCreateUserPage extends StatefulWidget {
  const AdminCreateUserPage({super.key, required this.initialRole});

  final String initialRole;

  @override
  State<AdminCreateUserPage> createState() => _AdminCreateUserPageState();
}

class _AdminCreateUserPageState extends State<AdminCreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();

  late String _role;
  String? _branchId;
  final Set<String> _managedBranchIds = {};
  List<BranchModel> _branches = [];
  bool _loadingBranches = true;
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _role = _kRoles.contains(widget.initialRole)
        ? widget.initialRole
        : 'BRANCH_MANAGER';
    _loadBranches();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _fullName.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    try {
      final list = await getIt<BranchRemoteDataSource>().getBranches();
      if (mounted) {
        setState(() {
          _branches = list;
          _loadingBranches = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingBranches = false);
      }
    }
  }

  bool get _needsBranch =>
      _role == 'CASHIER' || _role == 'INVENTORY_STAFF';

  bool get _needsManagedBranches => _role == 'BRANCH_MANAGER';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_needsBranch && (_branchId == null || _branchId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn chi nhánh')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await getIt<AdminUserRemoteDataSource>().createUser(
        username: _username.text,
        password: _password.text,
        fullName: _fullName.text,
        role: _role,
        branchId: _needsBranch ? _branchId : null,
        managedBranchIds:
            _needsManagedBranches && _managedBranchIds.isNotEmpty
                ? _managedBranchIds.toList()
                : null,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminOnlyPage(
      title: 'Thêm người dùng',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Thêm người dùng'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Bắt buộc';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Bắt buộc';
                if (v.length < 6) return 'Tối thiểu 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fullName,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_role),
              initialValue: _role,
              decoration: const InputDecoration(
                labelText: 'Vai trò',
                border: OutlineInputBorder(),
              ),
              items: _kRoles
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(_roleLabel(r)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _role = v;
                  if (!_needsBranch) _branchId = null;
                });
              },
            ),
            if (_needsBranch) ...[
              const SizedBox(height: 16),
              if (_loadingBranches)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
              else
                DropdownButtonFormField<String?>(
                  key: ValueKey('br_$_role$_branchId'),
                  initialValue: _branchId,
                  decoration: const InputDecoration(
                    labelText: 'Chi nhánh làm việc',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('— Chọn —'),
                    ),
                    ..._branches.map(
                      (b) => DropdownMenuItem<String?>(
                        value: b.id,
                        child: Text(b.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _branchId = v),
                ),
            ],
            if (_needsManagedBranches) ...[
              const SizedBox(height: 16),
              Text(
                'Chi nhánh quản lý (tùy chọn)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (_loadingBranches)
                const Center(child: CircularProgressIndicator())
              else if (_branches.isEmpty)
                const Text('Chưa có chi nhánh')
              else
                ..._branches.map((b) {
                  final sel = _managedBranchIds.contains(b.id);
                  return CheckboxListTile(
                    value: sel,
                    onChanged: (on) {
                      setState(() {
                        if (on == true) {
                          _managedBranchIds.add(b.id);
                        } else {
                          _managedBranchIds.remove(b.id);
                        }
                      });
                    },
                    title: Text(b.name),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Tạo tài khoản'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
