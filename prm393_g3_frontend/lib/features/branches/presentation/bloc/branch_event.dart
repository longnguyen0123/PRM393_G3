import 'package:equatable/equatable.dart';
import '../../domain/entities/branch.dart';

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object?> get props => [];
}

class BranchRequested extends BranchEvent {}

class BranchCreateRequested extends BranchEvent {
  final Branch branch;

  const BranchCreateRequested(this.branch);

  @override
  List<Object?> get props => [branch];
}