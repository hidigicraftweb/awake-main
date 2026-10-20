import 'package:equatable/equatable.dart';

abstract class CityEvent extends Equatable {
  const CityEvent();

  @override
  List<Object?> get props => [];
}

class CitiesFetchRequested extends CityEvent {
  const CitiesFetchRequested();
}

class CityFetchRequested extends CityEvent {
  final String identifier;

  const CityFetchRequested({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}
