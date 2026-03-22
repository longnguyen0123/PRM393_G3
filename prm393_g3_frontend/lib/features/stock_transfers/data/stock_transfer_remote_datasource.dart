import '../../../../core/network/api_client.dart';

String _parseId(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final oid = v[r'$oid'];
    if (oid is String) return oid;
    final id = v['_id'];
    if (id is Map && id[r'$oid'] is String) return id[r'$oid'] as String;
    if (id != null) return _parseId(id);
  }
  return v.toString();
}

String _branchRefId(dynamic v) {
  if (v is Map) return _parseId(v['_id']);
  return _parseId(v);
}

String? _branchRefName(dynamic v) {
  if (v is Map) return v['name'] as String?;
  return null;
}

class StockTransferRemoteDataSource {
  StockTransferRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> listTransfers({String? status}) async {
    final q = status != null && status.isNotEmpty ? '?status=$status' : '';
    final res = await _api.get('/stock-movements/transfers$q');
    final data = res.data['data'] as List? ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> getTransfer(String id) async {
    final res = await _api.get('/stock-movements/transfers/$id');
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<Map<String, dynamic>> createTransfer({
    required String fromBranchId,
    required String toBranchId,
    String? note,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _api.post(
      '/stock-movements/transfers',
      data: {
        'fromBranchId': fromBranchId,
        'toBranchId': toBranchId,
        if (note != null && note.isNotEmpty) 'note': note,
        'items': items,
      },
    );
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<Map<String, dynamic>> updateTransfer({
    required String id,
    String? toBranchId,
    String? note,
    List<Map<String, dynamic>>? items,
  }) async {
    final body = <String, dynamic>{};
    if (toBranchId != null) body['toBranchId'] = toBranchId;
    if (note != null) body['note'] = note;
    if (items != null) body['items'] = items;
    final res = await _api.patch('/stock-movements/transfers/$id', data: body);
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<Map<String, dynamic>> approveTransfer(String id) async {
    final res = await _api.post('/stock-movements/transfers/$id/approve');
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<Map<String, dynamic>> rejectTransfer(
    String id, {
    required String rejectionReason,
  }) async {
    final res = await _api.post(
      '/stock-movements/transfers/$id/reject',
      data: {'rejectionReason': rejectionReason},
    );
    return Map<String, dynamic>.from(res.data['data'] as Map);
  }

  Future<List<Map<String, dynamic>>> getTransferDestinationBranches() async {
    final res = await _api.get('/branches/transfer-destinations');
    final data = res.data['data'] as List? ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

/// Tiện ích parse từ JSON movement (dùng ở UI).
class StockTransferView {
  StockTransferView({
    required this.id,
    required this.status,
    required this.fromBranchId,
    required this.toBranchId,
    this.fromBranchName,
    this.toBranchName,
    this.note,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.creatorLabel,
    this.reviewerLabel,
    this.reviewedAt,
  });

  final String id;
  final String status;
  final String fromBranchId;
  final String toBranchId;
  final String? fromBranchName;
  final String? toBranchName;
  final String? note;
  final String? rejectionReason;
  final String? createdAt;
  final String? updatedAt;
  final List<StockTransferItemView> items;
  final String? creatorLabel;
  final String? reviewerLabel;
  final String? reviewedAt;

  factory StockTransferView.fromJson(Map<String, dynamic> j) {
    final rawItems = j['items'] as List? ?? [];
    return StockTransferView(
      id: _parseId(j['_id']),
      status: j['status'] as String? ?? '',
      fromBranchId: _branchRefId(j['fromBranchId']),
      toBranchId: _branchRefId(j['toBranchId']),
      fromBranchName: _branchRefName(j['fromBranchId']),
      toBranchName: _branchRefName(j['toBranchId']),
      note: j['note'] as String?,
      rejectionReason: j['rejectionReason'] as String?,
      createdAt: j['createdAt'] as String?,
      updatedAt: j['updatedAt'] as String?,
      items: rawItems.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return StockTransferItemView(
          variantId: _parseId(m['variantId']),
          quantity: (m['quantity'] as num?)?.toInt() ?? 0,
        );
      }).toList(),
      creatorLabel: _creatorLabel(j['createdBy']),
      reviewerLabel: _creatorLabel(j['reviewedBy']),
      reviewedAt: j['reviewedAt'] as String?,
    );
  }
}

String? _creatorLabel(dynamic v) {
  if (v is! Map) return null;
  final fn = v['fullName'] as String?;
  final un = v['username'] as String?;
  if (fn != null && fn.isNotEmpty) return fn;
  return un;
}

class StockTransferItemView {
  const StockTransferItemView({
    required this.variantId,
    required this.quantity,
  });

  final String variantId;
  final int quantity;
}
