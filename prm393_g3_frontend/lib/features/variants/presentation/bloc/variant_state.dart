part of 'variant_bloc.dart';

enum VariantStatus { initial, loading, success, failure }

class VariantState extends Equatable {
  const VariantState({
    required this.status,
    required this.variants,
    this.errorMessage,
  });

  const VariantState.initial()
      : status = VariantStatus.initial,
        variants = const [],
        errorMessage = null;

  final VariantStatus status;
  final List<Variant> variants;
  final String? errorMessage;

  VariantState copyWith({
    VariantStatus? status,
    List<Variant>? variants,
    String? errorMessage,
  }) {
    return VariantState(
      status: status ?? this.status,
      variants: variants ?? this.variants,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, variants, errorMessage];
}
