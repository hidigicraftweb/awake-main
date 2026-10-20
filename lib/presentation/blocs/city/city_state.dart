import 'package:equatable/equatable.dart';

import '../../../domain/entities/city.dart';

abstract class CityState extends Equatable {
  const CityState();

  @override
  List<Object?> get props => [];
}

class CityInitial extends CityState {
  const CityInitial();
}

class CityLoading extends CityState {
  const CityLoading();
}

class CitiesLoaded extends CityState {
  final List<City> cities;

  const CitiesLoaded({required this.cities});

  @override
  List<Object?> get props => [cities];
}

class CityLoaded extends CityState {
  final City city;

  const CityLoaded({required this.city});

  @override
  List<Object?> get props => [city];
}

class CityError extends CityState {
  final String message;

  const CityError({required this.message});

  @override
  List<Object?> get props => [message];
}
