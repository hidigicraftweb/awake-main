import '../../core/network/api_endpoints.dart';
import '../../domain/entities/cafe.dart';

class CafeModel extends Cafe {
  const CafeModel({
    required super.id,
    required super.name,
    required super.slug,
    super.thumbnail,
    super.thumbnailUrl,
    super.about,
    super.facilities = const [],
    super.city,
    super.photos = const [],
    super.photosUrl = const [],
    super.managerName,
    super.timeSlots = const [],
  });

  /// Factory for list item response (less fields)
  factory CafeModel.fromJson(Map<String, dynamic> json) {
    final thumbnailUrlPath = json['thumbnail_url'] as String?;
    final fullThumbnailUrl = ApiEndpoints.getFullStorageUrl(thumbnailUrlPath);

    return CafeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      thumbnailUrl: fullThumbnailUrl,
      about: json['about'] as String?,
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'] as List)
          : [],
      city: json['city'] != null
          ? CafeCityModel.fromJson(json['city'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Factory for detailed response (all fields)
  factory CafeModel.fromDetailJson(Map<String, dynamic> json) {
    final thumbnailUrlPath = json['thumbnail_url'] as String?;
    final fullThumbnailUrl = ApiEndpoints.getFullStorageUrl(thumbnailUrlPath);

    // Convert photos_url list to full URLs
    final photosUrlList = json['photos_url'] != null
        ? (json['photos_url'] as List)
            .map((url) => ApiEndpoints.getFullStorageUrl(url as String?))
            .where((url) => url != null)
            .cast<String>()
            .toList()
        : <String>[];

    return CafeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      thumbnailUrl: fullThumbnailUrl,
      about: json['about'] as String?,
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'] as List)
          : [],
      city: json['city'] != null
          ? CafeCityModel.fromJson(json['city'] as Map<String, dynamic>)
          : null,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : [],
      photosUrl: photosUrlList,
      managerName: json['manager_name'] as String?,
      timeSlots: json['time_slots'] != null
          ? (json['time_slots'] as List)
              .map((slot) =>
                  CafeTimeSlotModel.fromJson(slot as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'thumbnail': thumbnail,
      'thumbnail_url': thumbnailUrl,
      'about': about,
      'facilities': facilities,
      'city': city != null
          ? {
              'id': city!.id,
              'name': city!.name,
              'slug': (city as CafeCityModel?)?.slug,
            }
          : null,
      'photos': photos,
      'photos_url': photosUrl,
      'manager_name': managerName,
      'time_slots': timeSlots
          .map((slot) => {
                'id': slot.id,
                'day_of_week': slot.dayOfWeek,
                'day_name': slot.dayName,
                'start_time': slot.startTime,
                'end_time': slot.endTime,
                'is_active': slot.isActive,
              })
          .toList(),
    };
  }

  Cafe toEntity() {
    return Cafe(
      id: id,
      name: name,
      slug: slug,
      thumbnail: thumbnail,
      thumbnailUrl: thumbnailUrl,
      about: about,
      facilities: facilities,
      city: city,
      photos: photos,
      photosUrl: photosUrl,
      managerName: managerName,
      timeSlots: timeSlots,
    );
  }
}

class CafeCityModel extends CafeCity {
  const CafeCityModel({
    required super.id,
    required super.name,
    super.slug,
  });

  factory CafeCityModel.fromJson(Map<String, dynamic> json) {
    return CafeCityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
    );
  }
}

class CafeTimeSlotModel extends CafeTimeSlot {
  const CafeTimeSlotModel({
    required super.id,
    required super.dayOfWeek,
    super.dayName,
    super.startTime,
    super.endTime,
    super.isActive = true,
  });

  factory CafeTimeSlotModel.fromJson(Map<String, dynamic> json) {
    return CafeTimeSlotModel(
      id: json['id'] as int,
      dayOfWeek: json['day_of_week'] as int,
      dayName: json['day_name'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
