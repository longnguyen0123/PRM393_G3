import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_detail.dart';
import '../../domain/repositories/branch_repository.dart';
import 'edit_branch_page.dart';

bool _candidateAlreadyOnBranch(BranchManagerCandidate c, String branchId) {
  return c.assignedBranchIds.contains(branchId);
}

class _AddInventoryStaffDialog extends StatefulWidget {
  const _AddInventoryStaffDialog({
    required this.branchId,
    required this.onCreated,
    required this.showError,
  });

  final String branchId;
  final VoidCallback onCreated;
  final void Function(String message) showError;

  @override
  State<_AddInventoryStaffDialog> createState() =>
      _AddInventoryStaffDialogState();
}

class _AddInventoryStaffDialogState extends State<_AddInventoryStaffDialog> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _fullNameCtrl;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _fullNameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;
    final n = _fullNameCtrl.text.trim();
    if (u.isEmpty || p.isEmpty || n.isEmpty) return;
    final nav = Navigator.of(context);
    final repo = getIt<BranchRepository>();
    try {
      await repo.createInventoryStaff(
        widget.branchId,
        username: u,
        password: p,
        fullName: n,
      );
      if (!mounted) return;
      nav.pop();
      widget.onCreated();
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException
          ? (e.response?.data?.toString() ?? e.message ?? 'Lỗi')
          : e.toString();
      widget.showError(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm nhân viên kho'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
            ),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            TextField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}

class _AddCashierDialog extends StatefulWidget {
  const _AddCashierDialog({
    required this.branchId,
    required this.onCreated,
    required this.showError,
  });

  final String branchId;
  final VoidCallback onCreated;
  final void Function(String message) showError;

  @override
  State<_AddCashierDialog> createState() => _AddCashierDialogState();
}

class _AddCashierDialogState extends State<_AddCashierDialog> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _fullNameCtrl;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _fullNameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;
    final n = _fullNameCtrl.text.trim();
    if (u.isEmpty || p.isEmpty || n.isEmpty) return;
    final nav = Navigator.of(context);
    final repo = getIt<BranchRepository>();
    try {
      await repo.createCashier(
        widget.branchId,
        username: u,
        password: p,
        fullName: n,
      );
      if (!mounted) return;
      nav.pop();
      widget.onCreated();
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException
          ? (e.response?.data?.toString() ?? e.message ?? 'Lỗi')
          : e.toString();
      widget.showError(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm thu ngân'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
            ),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            TextField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}

class BranchDetailPage extends StatefulWidget {
  const BranchDetailPage({
    super.key,
    required this.branchId,
    this.titleFallback,
  });

  final String branchId;
  final String? titleFallback;

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  late Future<BranchDetail> _future;
  Future<List<InventoryStaffMember>>? _staffFuture;
  Future<List<InventoryStaffMember>>? _cashiersFuture;

  @override
  void initState() {
    super.initState();
    _reloadDetail();
  }

  void _reloadDetail() {
    _future = getIt<BranchRepository>().getBranchDetail(widget.branchId);
  }

  void _reloadStaff() {
    _staffFuture = getIt<BranchRepository>().getInventoryStaff(widget.branchId);
  }

  void _reloadCashiers() {
    _cashiersFuture = getIt<BranchRepository>().getCashiers(widget.branchId);
  }

  void _ensureStaffFuture(AuthState auth, Branch branch) {
    if (!_canViewBranchOperationalStaff(auth)) {
      _staffFuture = null;
      return;
    }
    _staffFuture ??=
        getIt<BranchRepository>().getInventoryStaff(widget.branchId);
  }

  void _ensureCashiersFuture(AuthState auth, Branch branch) {
    if (!_canViewBranchOperationalStaff(auth)) {
      _cashiersFuture = null;
      return;
    }
    _cashiersFuture ??= getIt<BranchRepository>().getCashiers(widget.branchId);
  }

  String _formatVnd(int? price) {
    if (price == null) return '—';
    final s = price.toString();
    final buf = StringBuffer();
    final len = s.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buf.write('.');
      }
      buf.write(s[i]);
    }
    return '${buf.toString()} đ';
  }

  Future<void> _openEdit(BuildContext context, BranchDetail detail) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditBranchPage(branch: detail.branch),
      ),
    );
    if (!context.mounted) return;
    if (result == 'updated') {
      setState(() {
        _reloadDetail();
        _staffFuture = null;
        _cashiersFuture = null;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Branch updated successfully'),
          ),
        );
    }
  }

  Future<void> _openAddManager(BuildContext context) async {
    final repo = getIt<BranchRepository>();
    String? selectedId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Thêm quản lý chi nhánh'),
              content: SizedBox(
                width: double.maxFinite,
                child: FutureBuilder<List<BranchManagerCandidate>>(
                  future: repo.getBranchManagerCandidates(widget.branchId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasError) {
                      return Text('Không tải được danh sách: ${snap.error}');
                    }
                    final all = snap.data ?? [];
                    final candidates = all
                        .where(
                          (c) => !_candidateAlreadyOnBranch(c, widget.branchId),
                        )
                        .toList();
                    if (candidates.isEmpty) {
                      return const Text(
                        'Không còn ứng viên nào chưa được gán vào chi nhánh này.',
                      );
                    }
                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Chọn quản lý',
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        isDense: true,
                        underline: const SizedBox.shrink(),
                        value: selectedId != null &&
                                candidates.any((c) => c.id == selectedId)
                            ? selectedId
                            : null,
                        items: candidates
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.fullName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setLocal(() => selectedId = v),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (selectedId == null || selectedId!.isEmpty) return;
                    final nav = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    try {
                      await repo.assignBranchManager(
                        widget.branchId,
                        selectedId,
                      );
                      if (!context.mounted) return;
                      nav.pop();
                      setState(_reloadDetail);
                      messenger
                        ?..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm quản lý cho chi nhánh'),
                          ),
                        );
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      messenger
                        ?..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              e is DioException
                                  ? (e.response?.data?.toString() ??
                                      e.message ??
                                      'Lỗi')
                                  : e.toString(),
                            ),
                          ),
                        );
                    }
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmRemoveManager(
    BuildContext context,
    BranchManagerInfo mgr,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gỡ quản lý'),
        content: Text(
          'Gỡ ${mgr.fullName} khỏi chi nhánh này? (Họ vẫn có thể quản lý chi nhánh khác.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Gỡ'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<BranchRepository>().assignBranchManager(
        widget.branchId,
        mgr.id,
        detach: true,
      );
      if (!context.mounted) return;
      setState(_reloadDetail);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Đã gỡ quản lý khỏi chi nhánh')),
        );
    } catch (e) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e is DioException
                  ? (e.response?.data?.toString() ?? e.message ?? 'Lỗi')
                  : e.toString(),
            ),
          ),
        );
    }
  }

  Future<void> _confirmClearAllManagers(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gỡ toàn bộ quản lý'),
        content: const Text(
          'Gỡ mọi Branch Manager khỏi chi nhánh này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Gỡ hết'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<BranchRepository>().assignBranchManager(
        widget.branchId,
        null,
      );
      if (!context.mounted) return;
      setState(_reloadDetail);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Đã gỡ toàn bộ quản lý')),
        );
    } catch (e) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e is DioException
                  ? (e.response?.data?.toString() ?? e.message ?? 'Lỗi')
                  : e.toString(),
            ),
          ),
        );
    }
  }

  Future<void> _openAddInventoryStaff(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AddInventoryStaffDialog(
        branchId: widget.branchId,
        onCreated: () {
          if (!context.mounted) return;
          setState(_reloadStaff);
          ScaffoldMessenger.maybeOf(context)
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Đã tạo nhân viên kho')),
            );
        },
        showError: (msg) {
          if (!context.mounted) return;
          ScaffoldMessenger.maybeOf(context)
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg)));
        },
      ),
    );
  }

  Future<void> _openAddCashier(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AddCashierDialog(
        branchId: widget.branchId,
        onCreated: () {
          if (!context.mounted) return;
          setState(_reloadCashiers);
          ScaffoldMessenger.maybeOf(context)
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Đã tạo tài khoản thu ngân')),
            );
        },
        showError: (msg) {
          if (!context.mounted) return;
          ScaffoldMessenger.maybeOf(context)
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg)));
        },
      ),
    );
  }

  Future<void> _confirmDeactivateStaff(
    BuildContext context,
    InventoryStaffMember s,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vô hiệu hóa tài khoản'),
        content: Text('Vô hiệu hóa ${s.fullName} (${s.username})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vô hiệu hóa'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<BranchRepository>().deactivateInventoryStaff(
        widget.branchId,
        s.id,
      );
      if (!context.mounted) return;
      setState(_reloadStaff);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Đã vô hiệu hóa tài khoản')),
        );
    } catch (e) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e is DioException
                  ? (e.response?.data?.toString() ?? e.message ?? 'Lỗi')
                  : e.toString(),
            ),
          ),
        );
    }
  }

  Future<void> _confirmDeactivateCashier(
    BuildContext context,
    InventoryStaffMember s,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vô hiệu hóa tài khoản'),
        content: Text('Vô hiệu hóa thu ngân ${s.fullName} (${s.username})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vô hiệu hóa'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<BranchRepository>().deactivateCashier(
        widget.branchId,
        s.id,
      );
      if (!context.mounted) return;
      setState(_reloadCashiers);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Đã vô hiệu hóa thu ngân')),
        );
    } catch (e) {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e is DioException
                  ? (e.response?.data?.toString() ?? e.message ?? 'Lỗi')
                  : e.toString(),
            ),
          ),
        );
    }
  }

  bool _canManageManagers(AuthState auth) =>
      auth is AuthAuthenticated && auth.user.role == 'ADMIN';

  /// Admin hoặc Branch Manager (chi nhánh đã được API kiểm tra qua danh sách / detail).
  bool _canViewBranchOperationalStaff(AuthState auth) =>
      auth is AuthAuthenticated &&
      (auth.user.role == 'ADMIN' || auth.user.role == 'BRANCH_MANAGER');

  /// Admin luôn được thao tác; Branch Manager chỉ khi admin đã giao quyền quản lý nhân sự tại kho.
  bool _canManageBranchOperationalStaff(AuthState auth, Branch branch) {
    if (auth is! AuthAuthenticated) return false;
    if (auth.user.role == 'ADMIN') return true;
    if (auth.user.role == 'BRANCH_MANAGER') {
      return branch.inventoryDelegatedToManager;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BranchDetail>(
      future: _future,
      builder: (context, snapshot) {
        final detail = snapshot.data;
        final title = detail?.branch.name ?? widget.titleFallback ?? 'Chi nhánh';

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final canEditBranch = detail != null &&
                authState is AuthAuthenticated &&
                authState.user.role == 'ADMIN';
            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  if (canEditBranch)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openEdit(context, detail),
                    ),
                ],
              ),
              body: _buildBody(context, snapshot, authState),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<BranchDetail> snapshot,
    AuthState authState,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      final msg = snapshot.error is DioException
          ? (snapshot.error as DioException).message ?? 'Lỗi mạng'
          : snapshot.error.toString();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(msg, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _reloadDetail();
                    _staffFuture = null;
                    _cashiersFuture = null;
                  });
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    final detail = snapshot.data!;
    final b = detail.branch;
    final managers = detail.branchManagers;
    final showManagers = _canManageManagers(authState);
    final showStaffSection = _canViewBranchOperationalStaff(authState);
    final canManageOperationalStaff =
        _canManageBranchOperationalStaff(authState, b);
    _ensureStaffFuture(authState, b);
    _ensureCashiersFuture(authState, b);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _reloadDetail();
          _staffFuture = null;
          _cashiersFuture = null;
        });
        await _future;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Thông tin chi nhánh',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(b.address)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(
                          b.status == 'ACTIVE' ? 'Đang hoạt động' : 'Ngưng',
                        ),
                        backgroundColor: b.status == 'ACTIVE'
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                      ),
                      Text('Tồn kho (tổng SL): ${b.totalItemsInStock}'),
                    ],
                  ),
                  if (showManagers) ...[
                    const SizedBox(height: 8),
                    Text(
                      b.inventoryDelegatedToManager
                          ? 'Giao quản lý kho cho Branch Manager: đã bật'
                          : 'Giao quản lý kho cho Branch Manager: chưa bật (sửa chi nhánh để bật)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (showManagers) ...[
            const SizedBox(height: 24),
            Text(
              'Quản lý chi nhánh (Branch Manager)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (managers.isEmpty)
                      const Text(
                        'Chưa gán Branch Manager nào cho chi nhánh này.',
                      )
                    else
                      ...managers.map(
                        (mgr) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(mgr.fullName),
                          subtitle: Text(
                            '${mgr.username} · ${mgr.status}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.link_off_outlined),
                            onPressed: () =>
                                _confirmRemoveManager(context, mgr),
                            tooltip: 'Gỡ khỏi chi nhánh này',
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openAddManager(context),
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Thêm quản lý'),
                        ),
                        if (managers.isNotEmpty)
                          TextButton(
                            onPressed: () =>
                                _confirmClearAllManagers(context),
                            child: const Text('Gỡ tất cả'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (showStaffSection) ...[
            const SizedBox(height: 24),
            Text(
              'Nhân viên kho',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (authState is AuthAuthenticated &&
                        authState.user.role == 'BRANCH_MANAGER' &&
                        !canManageOperationalStaff)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Admin chưa giao quyền quản lý nhân sự tại kho cho chi nhánh này. '
                          'Bạn vẫn xem được danh sách; thêm hoặc vô hiệu hóa khi được giao quyền.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    FutureBuilder<List<InventoryStaffMember>>(
                      future: _staffFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        if (snap.hasError) {
                          return Text(
                            'Không tải được danh sách nhân viên kho: ${snap.error}',
                          );
                        }
                        final staff = snap.data ?? [];
                        if (staff.isEmpty) {
                          return const Text(
                            'Chưa có nhân viên kho tại chi nhánh này.',
                          );
                        }
                        return Column(
                          children: staff
                              .map(
                                (s) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(s.fullName),
                                  subtitle: Text(
                                    '${s.username} · ${s.status}',
                                  ),
                                  trailing: canManageOperationalStaff &&
                                          s.status == 'ACTIVE'
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.block_outlined,
                                          ),
                                          onPressed: () =>
                                              _confirmDeactivateStaff(
                                                context,
                                                s,
                                              ),
                                          tooltip: 'Vô hiệu hóa',
                                        )
                                      : null,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    if (canManageOperationalStaff) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _openAddInventoryStaff(context),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Thêm nhân viên kho'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thu ngân (Cashier)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder<List<InventoryStaffMember>>(
                      future: _cashiersFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        if (snap.hasError) {
                          return Text(
                            'Không tải được danh sách thu ngân: ${snap.error}',
                          );
                        }
                        final cashiers = snap.data ?? [];
                        if (cashiers.isEmpty) {
                          return const Text(
                            'Chưa có thu ngân tại chi nhánh này.',
                          );
                        }
                        return Column(
                          children: cashiers
                              .map(
                                (s) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(s.fullName),
                                  subtitle: Text(
                                    '${s.username} · ${s.status}',
                                  ),
                                  trailing: canManageOperationalStaff &&
                                          s.status == 'ACTIVE'
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.block_outlined,
                                          ),
                                          onPressed: () =>
                                              _confirmDeactivateCashier(
                                                context,
                                                s,
                                              ),
                                          tooltip: 'Vô hiệu hóa',
                                        )
                                      : null,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    if (canManageOperationalStaff) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _openAddCashier(context),
                        icon: const Icon(Icons.point_of_sale_outlined),
                        label: const Text('Thêm thu ngân'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Tồn kho theo variant',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mỗi dòng là một SKU (variant) và số lượng tại chi nhánh.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          if (detail.products.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chưa có dòng tồn kho cho chi nhánh này.'),
              ),
            )
          else
            ...detail.products.map((line) {
              final sku = line.sku ?? '—';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '${line.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    sku,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số lượng tồn: ${line.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (line.productName != null &&
                          line.productName!.isNotEmpty)
                        Text('Sản phẩm: ${line.productName}'),
                      if (line.productDescription != null &&
                          line.productDescription!.isNotEmpty)
                        Text(line.productDescription!),
                      const SizedBox(height: 4),
                      if (line.barcode != null)
                        Text('Barcode: ${line.barcode}'),
                      Text('Mức đặt lại: ${line.reorderLevel}'),
                      Text('Giá niêm yết: ${_formatVnd(line.price)}'),
                      if (line.variantStatus != null &&
                          line.variantStatus!.isNotEmpty)
                        Text('Trạng thái variant: ${line.variantStatus}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }
}
