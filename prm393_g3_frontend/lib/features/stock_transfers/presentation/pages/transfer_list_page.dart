import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prm393_g3_frontend/core/di/service_locator.dart';
import 'package:prm393_g3_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:prm393_g3_frontend/features/stock_transfers/data/stock_transfer_remote_datasource.dart';
import 'package:prm393_g3_frontend/features/stock_transfers/presentation/pages/transfer_detail_page.dart';
import 'package:prm393_g3_frontend/features/stock_transfers/presentation/pages/transfer_form_page.dart';

class TransferListPage extends StatefulWidget {
  const TransferListPage({super.key});

  @override
  State<TransferListPage> createState() => _TransferListPageState();
}

class _TransferListPageState extends State<TransferListPage> {
  final _ds = getIt<StockTransferRemoteDataSource>();
  List<StockTransferView> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await _ds.listTransfers();
      if (!mounted) return;
      setState(() {
        _items = raw.map(StockTransferView.fromJson).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _messageFromError(e);
      });
    }
  }

  String _messageFromError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return e.toString();
  }

  bool _isInventoryStaff(UserEntity user) => user.role == 'INVENTORY_STAFF';

  bool _isManagerOrAdmin(UserEntity user) =>
      user.role == 'BRANCH_MANAGER' || user.role == 'ADMIN';

  bool _managerCanReview(UserEntity? user, StockTransferView t) {
    if (user == null) return false;
    if (user.role == 'ADMIN') return true;
    if (user.role != 'BRANCH_MANAGER') return false;
    final managed = <String>{
      ...?user.managedBranchIds,
      if (user.branchId != null) user.branchId!,
    };
    return managed.contains(t.fromBranchId);
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return s;
    }
  }

  Future<void> _approve(StockTransferView t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duyệt phiếu chuyển'),
        content: const Text(
          'Xác nhận duyệt? Tồn kho chi nhánh nguồn sẽ trừ và chi nhánh đích sẽ cộng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _ds.approveTransfer(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt phiếu')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFromError(e))),
      );
    }
  }

  Future<void> _reject(StockTransferView t) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối phiếu'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Lý do từ chối',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final reason = controller.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do')),
      );
      return;
    }
    try {
      await _ds.rejectTransfer(t.id, rejectionReason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã từ chối phiếu')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFromError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final staff = user != null && _isInventoryStaff(user);
        final managerSide = user != null && _isManagerOrAdmin(user);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Phiếu chuyển kho'),
          ),
          floatingActionButton: staff
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const TransferFormPage(),
                      ),
                    );
                    if (changed == true && mounted) _load();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo phiếu'),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: _load,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_error!, textAlign: TextAlign.center),
                          ),
                        ],
                      )
                    : _items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(child: Text('Chưa có phiếu chuyển')),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: _items.length,
                            itemBuilder: (context, i) {
                              final t = _items[i];
                              final fromName =
                                  t.fromBranchName ?? t.fromBranchId;
                              final toName = t.toBranchName ?? t.toBranchId;
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(t.status)
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _statusLabel(t.status),
                                              style: TextStyle(
                                                color: _statusColor(t.status),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            t.createdAt ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$fromName → $toName',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (t.creatorLabel != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tạo bởi: ${t.creatorLabel}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                      if (t.note != null &&
                                          t.note!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ghi chú: ${t.note}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                      if (t.status == 'REJECTED' &&
                                          t.rejectionReason != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lý do từ chối: ${t.rejectionReason}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                      if (t.items.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '${t.items.length} dòng hàng',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () async {
                                              final changed =
                                                  await Navigator.of(context)
                                                      .push<bool>(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      TransferDetailPage(
                                                    transferId: t.id,
                                                  ),
                                                ),
                                              );
                                              if (changed == true && mounted) {
                                                _load();
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 18,
                                            ),
                                            label: const Text('Chi tiết'),
                                          ),
                                          if (staff &&
                                              t.status == 'PENDING')
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                final changed =
                                                    await Navigator.of(context)
                                                        .push<bool>(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        TransferFormPage(
                                                      transferId: t.id,
                                                    ),
                                                  ),
                                                );
                                                if (changed == true &&
                                                    mounted) {
                                                  _load();
                                                }
                                              },
                                              icon: const Icon(Icons.edit,
                                                  size: 18),
                                              label: const Text('Sửa'),
                                            ),
                                          if (managerSide &&
                                              t.status == 'PENDING' &&
                                              _managerCanReview(user, t)) ...[
                                            FilledButton(
                                              onPressed: () => _approve(t),
                                              child: const Text('Duyệt'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => _reject(t),
                                              child: const Text('Từ chối'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        );
      },
    );
  }
}
