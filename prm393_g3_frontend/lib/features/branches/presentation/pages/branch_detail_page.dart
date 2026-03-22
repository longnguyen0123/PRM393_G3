import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/branch_detail.dart';
import '../../domain/repositories/branch_repository.dart';
import 'edit_branch_page.dart';

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

  @override
  void initState() {
    super.initState();
    _future = getIt<BranchRepository>().getBranchDetail(widget.branchId);
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
    if (result is String &&
        (result == 'updated' || result == 'deleted')) {
      if (result == 'deleted') {
        Navigator.of(context).pop(result);
        return;
      }
      setState(() {
        _future = getIt<BranchRepository>().getBranchDetail(widget.branchId);
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              result == 'updated'
                  ? 'Branch updated successfully'
                  : 'Branch deleted successfully',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BranchDetail>(
      future: _future,
      builder: (context, snapshot) {
        final detail = snapshot.data;
        final title = detail?.branch.name ?? widget.titleFallback ?? 'Chi nhánh';

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              if (detail != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openEdit(context, detail),
                ),
            ],
          ),
          body: _buildBody(context, snapshot),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<BranchDetail> snapshot) {
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
                    _future =
                        getIt<BranchRepository>().getBranchDetail(widget.branchId);
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
    final mgr = detail.branchManager;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _future = getIt<BranchRepository>().getBranchDetail(widget.branchId);
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quản lý chi nhánh',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: mgr == null
                  ? const Text('Chưa gán Branch Manager cho chi nhánh này.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mgr.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text('Tài khoản: ${mgr.username}'),
                        Text('Vai trò: ${mgr.role}'),
                        Text('Trạng thái: ${mgr.status}'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sản phẩm trong chi nhánh (theo tồn kho)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    line.productName ?? line.sku ?? 'Sản phẩm',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (line.productDescription != null &&
                          line.productDescription!.isNotEmpty)
                        Text(line.productDescription!),
                      const SizedBox(height: 4),
                      Text('SKU: ${line.sku ?? "—"}'),
                      if (line.barcode != null)
                        Text('Barcode: ${line.barcode}'),
                      Text(
                        'SL: ${line.quantity}  |  Mức đặt lại: ${line.reorderLevel}',
                      ),
                      Text('Giá niêm yết: ${_formatVnd(line.price)}'),
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
