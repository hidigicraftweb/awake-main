import 'package:equatable/equatable.dart';

class City extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? photo;
  final String? photoUrl;
  final int cafesCount;
  final DateTime? createdAt;

  const City({
    required this.id,
    required this.name,
    required this.slug,
    this.photo,
    this.photoUrl,
    required this.cafesCount,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        photo,
        photoUrl,
        cafesCount,
        createdAt,
      ];
}
