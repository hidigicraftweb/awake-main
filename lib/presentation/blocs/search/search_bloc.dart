import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) =>
          events.debounceTime(const Duration(milliseconds: 300)).flatMap(mapper),
    );
    on<SearchCleared>(_onSearchCleared);
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    final query = event.query.trim();
    emit(SearchState(query: query.isEmpty ? null : query));
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(const SearchState());
  }
}
