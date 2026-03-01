import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/variant.dart';
import '../../domain/usecases/get_variants_usecase.dart';

part 'variant_event.dart';
part 'variant_state.dart';

class VariantBloc extends Bloc<VariantEvent, VariantState> {
  VariantBloc({required this.getVariantsUseCase}) : super(const VariantState.initial()) {
    on<VariantRequested>(_onRequested);
    on<VariantRefreshed>(_onRequested);
  }

  final GetVariantsUseCase getVariantsUseCase;

  Future<void> _onRequested(VariantEvent event, Emitter<VariantState> emit) async {
    final productId = event is VariantRequested 
        ? event.productId 
        : (event as VariantRefreshed).productId;
    
    emit(state.copyWith(status: VariantStatus.loading));
    try {
      final variants = await getVariantsUseCase(productId);
      emit(state.copyWith(status: VariantStatus.success, variants: variants));
    } catch (e) {
      emit(state.copyWith(status: VariantStatus.failure, errorMessage: e.toString()));
    }
  }
}
