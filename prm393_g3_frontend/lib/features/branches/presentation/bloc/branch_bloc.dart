import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_branch.dart';
import '../../domain/usecases/create_branch.dart';
import '../../domain/entities/branch.dart';
import 'branch_event.dart';
import 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final GetBranches getBranches;
  final CreateBranch createBranch;

  BranchBloc({
    required this.getBranches,
    required this.createBranch,
  }) : super(BranchInitial()) {

    // GET LIST
    on<BranchRequested>((event, emit) async {
      emit(BranchLoading());
      try {
        final branches = await getBranches();
        emit(BranchLoaded(branches));
      } catch (e) {
        emit(BranchError(e.toString()));
      }
    });

    // CREATE
    on<BranchCreateRequested>((event, emit) async {
      emit(BranchLoading());
      try {
        await createBranch(event.branch);
        add(BranchRequested()); // refresh list automatically
      } catch (e) {
        emit(BranchError(e.toString()));
      }
    });
  }
}