import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_branch.dart';
import 'branch_event.dart';
import 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final GetBranches getBranches;

  BranchBloc(this.getBranches) : super(BranchInitial()) {
    on<BranchRequested>((event, emit) async {
      emit(BranchLoading());

      try {
        final branches = await getBranches();
        emit(BranchLoaded(branches));
      } catch (e) {
        emit(BranchError(e.toString()));
      }
    });
  }
}