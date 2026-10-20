import '../../core/network/api_endpoints.dart';
import '../../domain/entities/city.dart';

class CityModel extends City {
  const CityModel({
    required super.id,
    required super.name,
    required super.slug,
    super.photo,
    super.photoUrl,
    required super.cafesCount,
    super.createdAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final photoUrlPath = json['photo_url'] as String?;
    final fullPhotoUrl = ApiEndpoints.getFullStorageUrl(photoUrlPath);

    return CityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      photo: json['photo'] as String?,
      photoUrl: fullPhotoUrl,
      cafesCount: json['cafes_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'photo': photo,
      'photo_url': photoUrl,
      'cafes_count': cafesCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  City toEntity() {
    return City(
      id: id,
      name: name,
      slug: slug,
      photo: photo,
      photoUrl: photoUrl,
      cafesCount: cafesCount,
      createdAt: createdAt,
    );
  }
}
