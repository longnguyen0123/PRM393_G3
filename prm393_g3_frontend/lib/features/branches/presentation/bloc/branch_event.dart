import 'package:equatable/equatable.dart';

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object?> get props => [];
}

class BranchRequested extends BranchEvent {}