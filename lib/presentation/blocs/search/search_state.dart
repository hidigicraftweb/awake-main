import 'package:equatable/equatable.dart';

class SearchState extends Equatable {
  final String? query;

  const SearchState({this.query});

  @override
  List<Object?> get props => [query];
}
