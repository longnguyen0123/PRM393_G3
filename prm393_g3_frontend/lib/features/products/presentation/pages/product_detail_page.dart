import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/admin_only_page.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../domain/entities/product.dart';
import '../../../variants/presentation/pages/variant_list_page.dart';
import '../../../variants/presentation/bloc/variant_bloc.dart';
import 'edit_product_page.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  bool get _isActive => product.status.toUpperCase() == 'ACTIVE';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final desc = (product.description?.trim().isNotEmpty ?? false)
        ? product.description!.trim()
        : 'Chưa có mô tả';

    return AdminOnlyPage(
      title: 'Sản phẩm',
      child: Scaffold(
        backgroundColor: cs.surfaceContainerLowest,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: cs.surface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Chỉnh sửa',
              icon: Icon(Icons.edit_outlined, color: cs.primary),
              onPressed: () async {
                final result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => EditProductPage(product: product)),
                );
                if (!context.mounted) {
                  return;
                }
                if (result == 'updated') {
                  Navigator.of(context).pop('updated');
                }
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primaryContainer.withValues(alpha: 0.65),
                            cs.secondaryContainer.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cs.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.shadow.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 28,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                        color: cs.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _StatusChip(active: _isActive, scheme: cs),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                      child: Column(
                        children: [
                          _InfoTile(
                            icon: Icons.description_outlined,
                            label: 'Mô tả ngắn',
                            value: desc,
                            scheme: cs,
                            theme: theme,
                          ),
                          Divider(height: 1, indent: 56, color: cs.outlineVariant.withValues(alpha: 0.45)),
                          _InfoTile(
                            icon: Icons.storefront_outlined,
                            label: 'Thương hiệu',
                            value: product.brandName ?? '—',
                            scheme: cs,
                            theme: theme,
                          ),
                          Divider(height: 1, indent: 56, color: cs.outlineVariant.withValues(alpha: 0.45)),
                          _InfoTile(
                            icon: Icons.category_outlined,
                            label: 'Danh mục',
                            value: product.categoryName ?? '—',
                            scheme: cs,
                            theme: theme,
                          ),
                          Divider(height: 1, indent: 56, color: cs.outlineVariant.withValues(alpha: 0.45)),
                          _InfoTile(
                            icon: Icons.label_outline_rounded,
                            label: 'Trạng thái',
                            value: product.status,
                            scheme: cs,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.layers_outlined, size: 22, color: cs.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Biến thể (SKU)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Xem và quản lý các mã SKU, giá và trạng thái theo model này.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => getIt<VariantBloc>()
                                  ..add(VariantRequested(product.id)),
                                child: VariantListPage(
                                  productId: product.id,
                                  productName: product.name,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 20),
                        label: const Text('Mở danh sách variant'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active, required this.scheme});

  final bool active;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? scheme.tertiaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check_circle_outline_rounded : Icons.pause_circle_outline_rounded,
              size: 16,
              color: active ? scheme.onTertiaryContainer : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              active ? 'Đang hoạt động' : 'Ngừng hoạt động',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: active ? scheme.onTertiaryContainer : scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: scheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.35,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
