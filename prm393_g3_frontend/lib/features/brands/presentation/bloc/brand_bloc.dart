import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/brand.dart';
import '../../domain/usecases/get_brands_usecase.dart';

part 'brand_event.dart';
part 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  BrandBloc({required this.getBrandsUseCase}) : super(const BrandState.initial()) {
    on<BrandRequested>(_onRequested);
    on<BrandRefreshed>(_onRequested);
  }

  final GetBrandsUseCase getBrandsUseCase;

  Future<void> _onRequested(BrandEvent event, Emitter<BrandState> emit) async {
    emit(state.copyWith(status: BrandStatus.loading));
    try {
      final brands = await getBrandsUseCase();
      emit(state.copyWith(status: BrandStatus.success, brands: brands));
    } catch (e) {
      emit(state.copyWith(status: BrandStatus.failure, errorMessage: e.toString()));
    }
  }
}
