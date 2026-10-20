import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/city_repository.dart';
import 'city_event.dart';
import 'city_state.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final CityRepository cityRepository;

  CityBloc({required this.cityRepository}) : super(const CityInitial()) {
    on<CitiesFetchRequested>(_onCitiesFetchRequested);
    on<CityFetchRequested>(_onCityFetchRequested);
  }

  Future<void> _onCitiesFetchRequested(
    CitiesFetchRequested event,
    Emitter<CityState> emit,
  ) async {
    emit(const CityLoading());

    final result = await cityRepository.getCities();

    result.fold(
      (failure) => emit(CityError(message: failure.message)),
      (cities) => emit(CitiesLoaded(cities: cities)),
    );
  }

  Future<void> _onCityFetchRequested(
    CityFetchRequested event,
    Emitter<CityState> emit,
  ) async {
    emit(const CityLoading());

    final result = await cityRepository.getCityByIdentifier(event.identifier);

    result.fold(
      (failure) => emit(CityError(message: failure.message)),
      (city) => emit(CityLoaded(city: city)),
    );
  }
}
