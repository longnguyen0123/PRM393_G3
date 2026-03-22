import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prm393_g3_frontend/core/di/service_locator.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:prm393_g3_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:prm393_g3_frontend/features/branches/domain/entities/branch_detail.dart';
import 'package:prm393_g3_frontend/features/branches/domain/repositories/branch_repository.dart';
import 'package:prm393_g3_frontend/features/stock_transfers/data/stock_transfer_remote_datasource.dart';

class TransferFormPage extends StatefulWidget {
  const TransferFormPage({super.key, this.transferId});

  /// null = tạo mới; có id = sửa phiếu PENDING
  final String? transferId;

  @override
  State<TransferFormPage> createState() => _TransferFormPageState();
}

class _FormLine {
  _FormLine({this.variantId, int quantity = 1})
      : qtyController = TextEditingController(text: quantity.toString());

  String? variantId;
  final TextEditingController qtyController;

  void dispose() => qtyController.dispose();
}

class _TransferFormPageState extends State<TransferFormPage> {
  final _ds = getIt<StockTransferRemoteDataSource>();
  final _branchRepo = getIt<BranchRepository>();
  final _noteController = TextEditingController();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _destBranches = [];
  String? _toBranchId;
  List<BranchProductLine> _inventoryLines = [];
  final List<_FormLine> _lines = [];

  bool get _isEdit => widget.transferId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    _noteController.dispose();
    super.dispose();
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

  Future<void> _bootstrap() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.user.role != 'INVENTORY_STAFF') {
      setState(() {
        _loading = false;
        _error = 'Chỉ nhân viên kho được tạo/sửa phiếu chuyển';
      });
      return;
    }
    final branchId = auth.user.branchId;
    if (branchId == null || branchId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Tài khoản chưa gán chi nhánh';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final destinations = await _ds.getTransferDestinationBranches();
      if (_isEdit) {
        final t = await _ds.getTransfer(widget.transferId!);
        final view = StockTransferView.fromJson(t);
        final detail = await _branchRepo.getBranchDetail(view.fromBranchId);
        if (!mounted) return;
        setState(() {
          _destBranches = destinations;
          _toBranchId = view.toBranchId;
          _inventoryLines = detail.products;
          _noteController.text = view.note ?? '';
          _lines.clear();
          for (final it in view.items) {
            _lines.add(
              _FormLine(variantId: it.variantId, quantity: it.quantity),
            );
          }
          if (_lines.isEmpty) {
            _lines.add(_FormLine());
          }
          _loading = false;
        });
      } else {
        final detail = await _branchRepo.getBranchDetail(branchId);
        if (!mounted) return;
        setState(() {
          _destBranches = destinations;
          _toBranchId = destinations.isNotEmpty
              ? _parseBranchId(destinations.first)
              : null;
          _inventoryLines = detail.products;
          _lines.clear();
          _lines.add(_FormLine());
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _errMsg(e);
      });
    }
  }

  String _parseBranchId(Map<String, dynamic> m) {
    final id = m['_id'];
    if (id is String) return id;
    if (id is Map && id[r'$oid'] is String) return id[r'$oid'] as String;
    return id.toString();
  }

  String _branchName(Map<String, dynamic> m) =>
      m['name'] as String? ?? _parseBranchId(m);

  Iterable<BranchProductLine> _variantsForPicker() {
    final allowed = <String, BranchProductLine>{};
    for (final p in _inventoryLines) {
      final vid = p.variantId;
      if (vid != null && vid.isNotEmpty && p.quantity > 0) {
        allowed[vid] = p;
      }
    }
    for (final line in _lines) {
      final vid = line.variantId;
      if (vid != null && !allowed.containsKey(vid)) {
        final inv =
            _inventoryLines.where((p) => p.variantId == vid).toList();
        if (inv.isNotEmpty) allowed[vid] = inv.first;
      }
    }
    return allowed.values;
  }

  Future<void> _submit() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final fromBranchId = auth.user.branchId;
    if (fromBranchId == null) return;

    if (_toBranchId == null || _toBranchId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn chi nhánh đích')),
      );
      return;
    }

    final items = <Map<String, dynamic>>[];
    for (final line in _lines) {
      final vid = line.variantId;
      if (vid == null || vid.isEmpty) continue;
      final q = int.tryParse(line.qtyController.text.trim()) ?? 0;
      if (q < 1) continue;
      items.add({'variantId': vid, 'quantity': q});
    }
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm ít nhất một dòng hàng hợp lệ')),
      );
      return;
    }

    for (final line in _lines) {
      final vid = line.variantId;
      if (vid == null || vid.isEmpty) continue;
      final q = int.tryParse(line.qtyController.text.trim()) ?? 0;
      if (q < 1) continue;
      final matches =
          _inventoryLines.where((p) => p.variantId == vid).toList();
      final stock = matches.isEmpty ? 0 : matches.first.quantity;
      if (q > stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Số lượng vượt tồn ($stock) cho variant đã chọn',
            ),
          ),
        );
        return;
      }
    }

    try {
      if (_isEdit) {
        await _ds.updateTransfer(
          id: widget.transferId!,
          toBranchId: _toBranchId,
          note: _noteController.text.trim(),
          items: items,
        );
      } else {
        await _ds.createTransfer(
          fromBranchId: fromBranchId,
          toBranchId: _toBranchId!,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          items: items,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Đã cập nhật phiếu' : 'Đã tạo phiếu'),
        ),
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Sửa phiếu chuyển' : 'Tạo phiếu chuyển')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Sửa phiếu chuyển' : 'Tạo phiếu chuyển')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final variants = _variantsForPicker().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa phiếu chuyển' : 'Tạo phiếu chuyển'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _toBranchId != null &&
                    _destBranches.any((b) => _parseBranchId(b) == _toBranchId)
                ? _toBranchId
                : null,
            decoration: const InputDecoration(
              labelText: 'Chi nhánh đích',
              border: OutlineInputBorder(),
            ),
            items: _destBranches
                .map(
                  (b) => DropdownMenuItem<String>(
                    value: _parseBranchId(b),
                    child: Text(_branchName(b)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _toBranchId = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hàng chuyển',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: () => setState(() {
                  _lines.add(_FormLine());
                }),
                icon: const Icon(Icons.add),
                label: const Text('Thêm dòng'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_lines.length, (index) {
            final line = _lines[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: line.variantId != null &&
                              variants.any((v) => v.variantId == line.variantId)
                          ? line.variantId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Variant (SKU)',
                        border: OutlineInputBorder(),
                      ),
                      items: variants
                          .map(
                            (v) => DropdownMenuItem<String>(
                              value: v.variantId,
                              child: Text(
                                '${v.sku ?? v.variantId} — ${v.productName ?? ''} (tồn ${v.quantity})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => line.variantId = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: line.qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Số lượng',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    if (_lines.length > 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _lines[index].dispose();
                              _lines.removeAt(index);
                            });
                          },
                          child: const Text('Xóa dòng'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: Text(_isEdit ? 'Lưu thay đổi' : 'Gửi phiếu'),
          ),
        ],
      ),
    );
  }
}
