import 'package:flutter/material.dart';

import '../../../../core/widgets/admin_only_page.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/admin_user_remote_datasource.dart';
import 'admin_create_user_page.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _listVersion = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCreateUser() async {
    final initialRole = _tabController.index == 0
        ? 'BRANCH_MANAGER'
        : 'INVENTORY_STAFF';
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminCreateUserPage(initialRole: initialRole),
      ),
    );
    if (ok == true && mounted) {
      setState(() => _listVersion++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminOnlyPage(
      title: 'Quản lý người dùng',
      child: Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Branch Manager'),
            Tab(text: 'Inventory Staff'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateUser,
        tooltip: 'Thêm người dùng',
        child: const Icon(Icons.person_add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BranchManagerTab(key: ValueKey('bm$_listVersion')),
          _InventoryStaffTab(key: ValueKey('is$_listVersion')),
        ],
      ),
    ),
    );
  }
}

class _BranchManagerTab extends StatefulWidget {
  const _BranchManagerTab({super.key});

  @override
  State<_BranchManagerTab> createState() => _BranchManagerTabState();
}

class _BranchManagerTabState extends State<_BranchManagerTab> {
  late Future<List<AdminBranchManagerRow>> _future;
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _future = getIt<AdminUserRemoteDataSource>().getBranchManagers();
  }

  Future<void> _reload() async {
    setState(() {
      _future = getIt<AdminUserRemoteDataSource>().getBranchManagers();
    });
    await _future;
  }

  Future<void> _setStatus(String id, bool active) async {
    if (_busyIds.contains(id)) return;
    setState(() => _busyIds.add(id));
    try {
      await getIt<AdminUserRemoteDataSource>().updateUserStatus(
        id,
        active ? 'ACTIVE' : 'INACTIVE',
      );
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<AdminBranchManagerRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Không tải được danh sách: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ],
            );
          }
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Chưa có Branch Manager')),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = rows[i];
              final branchText = r.branches.isEmpty
                  ? 'Chưa gán chi nhánh'
                  : r.branches
                      .map((b) => b.name.isEmpty ? b.id : b.name)
                      .join(', ');
              final busy = _busyIds.contains(r.id);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withValues(alpha: 0.2),
                    child: const Icon(Icons.manage_accounts, color: Colors.orange),
                  ),
                  title: Text(
                    r.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('@${r.username}'),
                      const SizedBox(height: 4),
                      Text('Chi nhánh: $branchText'),
                      Text(
                        busy
                            ? 'Đang cập nhật…'
                            : (r.status == 'ACTIVE'
                                ? 'Trạng thái: Hoạt động'
                                : 'Trạng thái: Vô hiệu'),
                        style: TextStyle(
                          color: r.status == 'ACTIVE'
                              ? Colors.green[700]
                              : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Switch(
                    value: r.status == 'ACTIVE',
                    onChanged: busy ? null : (v) => _setStatus(r.id, v),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InventoryStaffTab extends StatefulWidget {
  const _InventoryStaffTab({super.key});

  @override
  State<_InventoryStaffTab> createState() => _InventoryStaffTabState();
}

class _InventoryStaffTabState extends State<_InventoryStaffTab> {
  late Future<List<AdminInventoryStaffRow>> _future;
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _future = getIt<AdminUserRemoteDataSource>().getInventoryStaff();
  }

  Future<void> _reload() async {
    setState(() {
      _future = getIt<AdminUserRemoteDataSource>().getInventoryStaff();
    });
    await _future;
  }

  Future<void> _setStatus(String id, bool active) async {
    if (_busyIds.contains(id)) return;
    setState(() => _busyIds.add(id));
    try {
      await getIt<AdminUserRemoteDataSource>().updateUserStatus(
        id,
        active ? 'ACTIVE' : 'INACTIVE',
      );
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<AdminInventoryStaffRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Không tải được danh sách: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ],
            );
          }
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Chưa có Inventory Staff')),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = rows[i];
              final b = r.branch;
              final branchLine = b == null
                  ? 'Chưa gán chi nhánh'
                  : (b.name.isEmpty ? b.id : b.name);
              final addressLine =
                  b != null && b.address.isNotEmpty ? b.address : null;
              final busy = _busyIds.contains(r.id);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: 0.2),
                    child: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
                  ),
                  title: Text(
                    r.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('@${r.username}'),
                      const SizedBox(height: 4),
                      Text('Chi nhánh: $branchLine'),
                      if (addressLine != null) Text(addressLine),
                      Text(
                        busy
                            ? 'Đang cập nhật…'
                            : (r.status == 'ACTIVE'
                                ? 'Trạng thái: Hoạt động'
                                : 'Trạng thái: Vô hiệu'),
                        style: TextStyle(
                          color: r.status == 'ACTIVE'
                              ? Colors.green[700]
                              : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Switch(
                    value: r.status == 'ACTIVE',
                    onChanged: busy ? null : (v) => _setStatus(r.id, v),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
