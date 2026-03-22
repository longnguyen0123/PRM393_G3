import '../../../../core/network/api_client.dart';
import '../models/variant_model.dart';

abstract class VariantRemoteDataSource {
  Future<List<VariantModel>> fetchVariantsByProductId(String productId);
  Future<VariantModel> createVariant({
    required String productId,
    required String sku,
    String? barcode,
    required double price,
    String status,
  });
  Future<VariantModel> updateVariant(
    String id, {
    required String sku,
    required String? barcode,
    required double price,
    String status = 'ACTIVE',
  });
}

class VariantRemoteDataSourceImpl implements VariantRemoteDataSource {
  VariantRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<VariantModel>> fetchVariantsByProductId(String productId) async {
    final response = await apiClient.get('/variants?productId=$productId');
    final data = response.data as List<dynamic>;
    return data.map((item) => VariantModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<VariantModel> createVariant({
    required String productId,
    required String sku,
    String? barcode,
    required double price,
    String status = 'ACTIVE',
  }) async {
    final response = await apiClient.post(
      '/variants',
      data: {
        'productId': productId,
        'sku': sku,
        if (barcode != null && barcode.trim().isNotEmpty) 'barcode': barcode.trim(),
        'price': price,
        'status': status,
      },
    );
    return VariantModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<VariantModel> updateVariant(
    String id, {
    required String sku,
    required String? barcode,
    required double price,
    String status = 'ACTIVE',
  }) async {
    final response = await apiClient.patch(
      '/variants/$id',
      data: {
        'sku': sku,
        'price': price,
        'status': status,
        'barcode': barcode == null || barcode.isEmpty ? '' : barcode,
      },
    );
    return VariantModel.fromJson(response.data as Map<String, dynamic>);
  }
}
