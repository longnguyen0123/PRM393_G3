import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/brand.dart';
import '../../domain/usecases/create_brand.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/update_brand.dart';

part 'brand_event.dart';
part 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  BrandBloc({
    required this.getBrandsUseCase,
    required this.createBrand,
    required this.updateBrand,
  }) : super(const BrandState.initial()) {
    on<BrandRequested>(_onRequested);
    on<BrandRefreshed>(_onRequested);
    on<BrandCreateRequested>(_onCreate);
    on<BrandUpdateRequested>(_onUpdate);
  }

  final GetBrandsUseCase getBrandsUseCase;
  final CreateBrand createBrand;
  final UpdateBrand updateBrand;

  Future<void> _onRequested(BrandEvent event, Emitter<BrandState> emit) async {
    emit(state.copyWith(status: BrandStatus.loading));
    try {
      final brands = await getBrandsUseCase();
      emit(state.copyWith(status: BrandStatus.success, brands: brands, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: BrandStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(BrandCreateRequested event, Emitter<BrandState> emit) async {
    emit(state.copyWith(status: BrandStatus.loading));
    try {
      await createBrand(name: event.name, status: event.status);
      final brands = await getBrandsUseCase();
      emit(state.copyWith(status: BrandStatus.success, brands: brands, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: BrandStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdate(BrandUpdateRequested event, Emitter<BrandState> emit) async {
    emit(state.copyWith(status: BrandStatus.loading));
    try {
      await updateBrand(id: event.id, name: event.name, status: event.status);
      final brands = await getBrandsUseCase();
      emit(state.copyWith(status: BrandStatus.success, brands: brands, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: BrandStatus.failure, errorMessage: e.toString()));
    }
  }
}
