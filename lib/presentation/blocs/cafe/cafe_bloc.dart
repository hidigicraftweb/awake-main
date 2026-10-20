import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/cafe_repository.dart';
import 'cafe_event.dart';
import 'cafe_state.dart';

class CafeBloc extends Bloc<CafeEvent, CafeState> {
  final CafeRepository cafeRepository;

  CafeBloc({required this.cafeRepository}) : super(const CafeInitial()) {
    on<CafesByCityFetchRequested>(_onCafesByCityFetchRequested);
    on<PopularCafesFetchRequested>(_onPopularCafesFetchRequested);
    on<NewestCafesFetchRequested>(_onNewestCafesFetchRequested);
    on<CafeFetchRequested>(_onCafeFetchRequested);
  }

  Future<void> _onCafesByCityFetchRequested(
    CafesByCityFetchRequested event,
    Emitter<CafeState> emit,
  ) async {
    emit(const CafeLoading());

    final result = await cafeRepository.getCafesByCity(
      event.cityId,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(CafeError(message: failure.message)),
      (cafes) => emit(CafesLoaded(cafes: cafes)),
    );
  }

  Future<void> _onPopularCafesFetchRequested(
    PopularCafesFetchRequested event,
    Emitter<CafeState> emit,
  ) async {
    emit(const CafeLoading());

    final result = await cafeRepository.getPopularCafes(limit: event.limit);

    result.fold(
      (failure) => emit(CafeError(message: failure.message)),
      (cafes) => emit(CafesLoaded(cafes: cafes)),
    );
  }

  Future<void> _onNewestCafesFetchRequested(
    NewestCafesFetchRequested event,
    Emitter<CafeState> emit,
  ) async {
    emit(const CafeLoading());

    final result = await cafeRepository.getNewestCafes(limit: event.limit);

    result.fold(
      (failure) => emit(CafeError(message: failure.message)),
      (cafes) => emit(CafesLoaded(cafes: cafes)),
    );
  }

  Future<void> _onCafeFetchRequested(
    CafeFetchRequested event,
    Emitter<CafeState> emit,
  ) async {
    emit(const CafeLoading());

    final result = await cafeRepository.getCafeById(event.cafeId);

    result.fold(
      (failure) => emit(CafeError(message: failure.message)),
      (cafe) => emit(CafeLoaded(cafe: cafe)),
    );
  }
}
