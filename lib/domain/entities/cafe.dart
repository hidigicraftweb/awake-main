import 'package:equatable/equatable.dart';

class Cafe extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String? about;
  final List<String> facilities;
  final CafeCity? city;
  // Detailed fields (only available when fetching single cafe)
  final List<String> photos;
  final List<String> photosUrl;
  final String? managerName;
  final List<CafeTimeSlot> timeSlots;

  const Cafe({
    required this.id,
    required this.name,
    required this.slug,
    this.thumbnail,
    this.thumbnailUrl,
    this.about,
    this.facilities = const [],
    this.city,
    this.photos = const [],
    this.photosUrl = const [],
    this.managerName,
    this.timeSlots = const [],
  });

  /// Check if cafe is currently open based on time slots
  bool get isCurrentlyOpen {
    if (timeSlots.isEmpty) return true; // Assume open if no time slots

    final now = DateTime.now();
    // Convert Flutter weekday (1=Monday, 7=Sunday) to backend format (0=Sunday, 6=Saturday)
    final currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;

    final todaySlots = timeSlots.where(
      (slot) => slot.dayOfWeek == currentDayOfWeek && slot.isActive,
    );

    if (todaySlots.isEmpty) return false;

    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final slot in todaySlots) {
      if (slot.startTime != null && slot.endTime != null) {
        if (currentTime.compareTo(slot.startTime!) >= 0 &&
            currentTime.compareTo(slot.endTime!) <= 0) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get today's opening hours string
  String? get todayOpeningHours {
    if (timeSlots.isEmpty) return null;

    final now = DateTime.now();
    // Convert Flutter weekday (1=Monday, 7=Sunday) to backend format (0=Sunday, 6=Saturday)
    final currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;

    final todaySlots = timeSlots.where(
      (slot) => slot.dayOfWeek == currentDayOfWeek && slot.isActive,
    );

    if (todaySlots.isEmpty) return 'Closed Today';

    final todaySlot = todaySlots.first;

    if (todaySlot.startTime != null && todaySlot.endTime != null) {
      return '${todaySlot.startTime} - ${todaySlot.endTime}';
    }

    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        thumbnail,
        thumbnailUrl,
        about,
        facilities,
        city,
        photos,
        photosUrl,
        managerName,
        timeSlots,
      ];
}

class CafeCity extends Equatable {
  final int id;
  final String name;
  final String? slug;

  const CafeCity({
    required this.id,
    required this.name,
    this.slug,
  });

  @override
  List<Object?> get props => [id, name, slug];
}

class CafeTimeSlot extends Equatable {
  final int id;
  final int dayOfWeek;
  final String? dayName;
  final String? startTime;
  final String? endTime;
  final bool isActive;

  const CafeTimeSlot({
    required this.id,
    required this.dayOfWeek,
    this.dayName,
    this.startTime,
    this.endTime,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        dayOfWeek,
        dayName,
        startTime,
        endTime,
        isActive,
      ];
}
