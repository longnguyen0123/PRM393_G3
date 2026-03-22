import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/admin_only_page.dart';
import '../../domain/entities/variant.dart';
import '../../domain/usecases/update_variant_usecase.dart';

class EditVariantPage extends StatefulWidget {
  const EditVariantPage({
    super.key,
    required this.productName,
    required this.variant,
  });

  final String productName;
  final Variant variant;

  @override
  State<EditVariantPage> createState() => _EditVariantPageState();
}

class _EditVariantPageState extends State<EditVariantPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late String _status;
  bool _submitting = false;

  UpdateVariantUseCase get _updateVariant => getIt<UpdateVariantUseCase>();

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    _skuController = TextEditingController(text: v.sku);
    _barcodeController = TextEditingController(text: v.barcode ?? '');
    _priceController = TextEditingController(
      text: v.price == v.price.roundToDouble() ? '${v.price.toInt()}' : '${v.price}',
    );
    _status = v.status.isNotEmpty ? v.status : 'ACTIVE';
  }

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
    final barcodeTrim = _barcodeController.text.trim();
    try {
      await _updateVariant(
        widget.variant.id,
        sku: _skuController.text.trim(),
        barcode: barcodeTrim.isEmpty ? null : barcodeTrim,
        price: price,
        status: _status,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop('updated');
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null
          ? data['message'].toString()
          : e.message ?? 'Failed to update variant';
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
      title: 'Sửa variant',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit variant'),
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
                      child: const Text('Save changes'),
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
