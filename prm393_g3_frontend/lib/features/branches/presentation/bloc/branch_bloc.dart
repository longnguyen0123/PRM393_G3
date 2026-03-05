import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_branch.dart';
import '../../domain/usecases/create_branch.dart';
import '../../domain/usecases/update_branch.dart';
import '../../domain/usecases/delete_branch.dart';
import 'branch_event.dart';
import 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final GetBranches getBranches;
  final CreateBranch createBranch;
  final UpdateBranch updateBranch;
  final DeleteBranch deleteBranch;

  BranchBloc({
    required this.getBranches,
    required this.createBranch,
    required this.updateBranch,
    required this.deleteBranch,
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

    on<BranchUpdateRequested>((event, emit) async {
      emit(BranchLoading());
      try {
        await updateBranch(event.branch);
        add(BranchRequested()); // refresh list automatically
      } catch (e) {
        emit(BranchError(e.toString()));
      }
    });

    on<BranchDeleteRequested>((event, emit) async {
      emit(BranchLoading());
      try {
        await deleteBranch(event.branchId);
        add(BranchRequested()); // refresh list automatically
      } catch (e) {
        emit(BranchError(e.toString()));
      }
    });
  }
}