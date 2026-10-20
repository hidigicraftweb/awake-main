import 'package:equatable/equatable.dart';

import '../../../domain/entities/cafe.dart';

abstract class CafeState extends Equatable {
  const CafeState();

  @override
  List<Object?> get props => [];
}

class CafeInitial extends CafeState {
  const CafeInitial();
}

class CafeLoading extends CafeState {
  const CafeLoading();
}

class CafesLoaded extends CafeState {
  final List<Cafe> cafes;

  const CafesLoaded({required this.cafes});

  @override
  List<Object?> get props => [cafes];
}

class CafeLoaded extends CafeState {
  final Cafe cafe;

  const CafeLoaded({required this.cafe});

  @override
  List<Object?> get props => [cafe];
}

class CafeError extends CafeState {
  final String message;

  const CafeError({required this.message});

  @override
  List<Object?> get props => [message];
}
