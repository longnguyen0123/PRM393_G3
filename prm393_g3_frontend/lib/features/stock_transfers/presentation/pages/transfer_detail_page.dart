import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prm393_g3_frontend/core/di/service_locator.dart';
import 'package:prm393_g3_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:prm393_g3_frontend/features/branches/domain/repositories/branch_repository.dart';
import 'package:prm393_g3_frontend/features/stock_transfers/data/stock_transfer_remote_datasource.dart';

/// Chi tiết phiếu chuyển kho (NV kho / quản lý / admin).
class TransferDetailPage extends StatefulWidget {
  const TransferDetailPage({super.key, required this.transferId});

  final String transferId;

  @override
  State<TransferDetailPage> createState() => _TransferDetailPageState();
}

class _TransferDetailPageState extends State<TransferDetailPage> {
  final _ds = getIt<StockTransferRemoteDataSource>();
  final _branchRepo = getIt<BranchRepository>();

  StockTransferView? _transfer;
  Map<String, String> _skuByVariant = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _errMsg(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return e.toString();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await _ds.getTransfer(widget.transferId);
      final t = StockTransferView.fromJson(raw);
      final sku = <String, String>{};
      try {
        final detail = await _branchRepo.getBranchDetail(t.fromBranchId);
        for (final p in detail.products) {
          final vid = p.variantId;
          if (vid != null && vid.isNotEmpty) {
            sku[vid] = p.sku ?? p.productName ?? vid;
          }
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _transfer = t;
        _skuByVariant = sku;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _errMsg(e);
      });
    }
  }

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
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errMsg(e))),
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
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errMsg(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final managerSide = user != null &&
            (user.role == 'BRANCH_MANAGER' || user.role == 'ADMIN');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết phiếu chuyển'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loading ? null : _load,
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    )
                  : _transfer == null
                      ? const Center(child: Text('Không có dữ liệu'))
                      : _buildBody(user, managerSide, _transfer!),
        );
      },
    );
  }

  Widget _buildBody(
    UserEntity? user,
    bool managerSide,
    StockTransferView t,
  ) {
    final fromName = t.fromBranchName ?? t.fromBranchId;
    final toName = t.toBranchName ?? t.toBranchId;
    final canAct = managerSide &&
        t.status == 'PENDING' &&
        _managerCanReview(user, t);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(t.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(t.status),
                style: TextStyle(
                  color: _statusColor(t.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _detailRow('Từ chi nhánh', fromName),
        _detailRow('Đến chi nhánh', toName),
        if (t.createdAt != null && t.createdAt!.isNotEmpty)
          _detailRow('Tạo lúc', t.createdAt!),
        if (t.updatedAt != null && t.updatedAt!.isNotEmpty)
          _detailRow('Cập nhật', t.updatedAt!),
        if (t.creatorLabel != null)
          _detailRow('Người tạo', t.creatorLabel!),
        if (t.reviewedAt != null && t.reviewedAt!.isNotEmpty)
          _detailRow('Duyệt/từ chối lúc', t.reviewedAt!),
        if (t.reviewerLabel != null)
          _detailRow('Người duyệt', t.reviewerLabel!),
        if (t.note != null && t.note!.isNotEmpty)
          _detailRow('Ghi chú', t.note!),
        if (t.status == 'REJECTED' && t.rejectionReason != null)
          _detailRow('Lý do từ chối', t.rejectionReason!, emphasize: true),
        const SizedBox(height: 16),
        const Text(
          'Danh sách hàng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...t.items.map(
          (it) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(_skuByVariant[it.variantId] ?? it.variantId),
              subtitle: Text('Variant ID: ${it.variantId}'),
              trailing: Text(
                '× ${it.quantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (canAct) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => _approve(t),
                  child: const Text('Duyệt'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _reject(t),
                  child: const Text('Từ chối'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _detailRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: emphasize ? Colors.red : Colors.black87,
                fontWeight: emphasize ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
