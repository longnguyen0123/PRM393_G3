import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/admin_only_page.dart';
import '../../domain/usecases/create_variant_usecase.dart';

class CreateVariantPage extends StatefulWidget {
  const CreateVariantPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  State<CreateVariantPage> createState() => _CreateVariantPageState();
}

class _CreateVariantPageState extends State<CreateVariantPage> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  String _status = 'ACTIVE';
  bool _submitting = false;

  CreateVariantUseCase get _createVariant => getIt<CreateVariantUseCase>();

  @override
  void dispose() {
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _priceValidator(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Price is required';
    }
    final n = double.tryParse(v.trim().replaceAll(',', ''));
    if (n == null || n < 0) {
      return 'Enter a valid non-negative number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    setState(() => _submitting = true);
    final price = double.parse(_priceController.text.trim().replaceAll(',', ''));
    try {
      await _createVariant(
        productId: widget.productId,
        sku: _skuController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        price: price,
        status: _status,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop('created');
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null
          ? data['message'].toString()
          : e.message ?? 'Failed to create variant';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminOnlyPage(
      title: 'Tạo variant',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create variant'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.productName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          widget.productName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'SKU is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _priceValidator,
                    ),
                    const SizedBox(height: 8),
                    Text('Status', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(value: 'ACTIVE', label: Text('Active')),
                        ButtonSegment<String>(value: 'INACTIVE', label: Text('Inactive')),
                      ],
                      selected: {_status},
                      onSelectionChanged: (Set<String> selection) {
                        if (_submitting || selection.isEmpty) {
                          return;
                        }
                        setState(() => _status = selection.first);
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: const Text('Create variant'),
                    ),
                  ],
                ),
              ),
            ),
            if (_submitting)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
