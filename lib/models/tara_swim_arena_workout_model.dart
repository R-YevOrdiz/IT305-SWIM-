/// Tara Swim Arena Workout - Data Models
/// Following naming convention based on the proposed mobile app title:
/// tara_swim_arena_workout_model.dart
library;

class ArenaInfo {
  final String name;
  final String tagline;
  final String location;
  final String contact;
  final int totalServices;

  const ArenaInfo({
    required this.name,
    required this.tagline,
    required this.location,
    required this.contact,
    required this.totalServices,
  });

  factory ArenaInfo.fromJson(Map<String, dynamic> json) {
    return ArenaInfo(
      name: json['name'] as String? ?? 'Tara Swim Arena Workout Center',
      tagline: json['tagline'] as String? ?? 'Elite Aquatic Training & Swim Fitness Programs',
      location: json['location'] as String? ?? 'Olympic Aquatics Complex, Lane 1-8',
      contact: json['contact'] as String? ?? '+63 912 345 6789',
      totalServices: (json['totalServices'] as num?)?.toInt() ?? 6,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tagline': tagline,
      'location': location,
      'contact': contact,
      'totalServices': totalServices,
    };
  }
}

class WeeklySummary {
  final int sessionsCompleted;
  final int targetSessions;
  final int totalDistanceMeters;
  final int totalDurationMinutes;

  const WeeklySummary({
    required this.sessionsCompleted,
    required this.targetSessions,
    required this.totalDistanceMeters,
    required this.totalDurationMinutes,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      sessionsCompleted: (json['sessionsCompleted'] as num?)?.toInt() ?? 0,
      targetSessions: (json['targetSessions'] as num?)?.toInt() ?? 5,
      totalDistanceMeters: (json['totalDistanceMeters'] as num?)?.toInt() ?? 0,
      totalDurationMinutes: (json['totalDurationMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionsCompleted': sessionsCompleted,
      'targetSessions': targetSessions,
      'totalDistanceMeters': totalDistanceMeters,
      'totalDurationMinutes': totalDurationMinutes,
    };
  }
}

class SwimWorkoutService {
  final String id;
  final String title;
  final String category;
  final double price;
  final int durationMinutes;
  final int distanceMeters;
  final String status;
  final String coach;
  final double rating;
  final String date;
  final String description;
  final String icon;

  const SwimWorkoutService({
    required this.id,
    required this.title,
    required this.category,
    this.price = 450.0,
    required this.durationMinutes,
    required this.distanceMeters,
    required this.status,
    this.coach = 'Coach Ryan Billera',
    this.rating = 4.9,
    required this.date,
    this.description = 'High-performance swim session.',
    required this.icon,
  });

  factory SwimWorkoutService.fromJson(Map<String, dynamic> json) {
    return SwimWorkoutService(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Pool Workout',
      category: json['category'] as String? ?? 'General',
      price: (json['price'] as num?)?.toDouble() ?? 450.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Available',
      coach: json['coach'] as String? ?? 'Coach Ryan Billera',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? 'High-performance swim session.',
      icon: json['icon'] as String? ?? 'timer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'price': price,
      'durationMinutes': durationMinutes,
      'distanceMeters': distanceMeters,
      'status': status,
      'coach': coach,
      'rating': rating,
      'date': date,
      'description': description,
      'icon': icon,
    };
  }

  // Product Mapping Property Aliases
  String get name => title;
  String get productName => title;
}

/// ==========================================
/// 2. JSON ARRAY TO PRODUCT MAPPING
/// Typedefs for Product / SwimWorkoutProduct
/// ==========================================
typedef Product = SwimWorkoutService;
typedef SwimWorkoutProduct = SwimWorkoutService;
typedef SwimProduct = SwimWorkoutService;
typedef WorkoutSession = SwimWorkoutService;

class TaraSwimArenaWorkoutDashboardData {
  final ArenaInfo arenaInfo;
  final WeeklySummary weeklySummary;
  final List<SwimWorkoutService> services;

  List<SwimWorkoutService> get sessions => services;
  List<Product> get products => services;

  /// Helper method for JSON Array to Product Mapping
  static List<Product> mapJsonArrayToProducts(List<dynamic> jsonArray) {
    return jsonArray
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  const TaraSwimArenaWorkoutDashboardData({
    required this.arenaInfo,
    required this.weeklySummary,
    required this.services,
  });

  factory TaraSwimArenaWorkoutDashboardData.fromJson(Map<String, dynamic> json) {
    final arenaJson = json['arenaInfo'] as Map<String, dynamic>?;
    final summaryJson = json['weeklySummary'] as Map<String, dynamic>?;
    final servicesList = (json['services'] ?? json['sessions']) as List<dynamic>?;

    final parsedServices = servicesList != null
        ? servicesList
            .map((item) => SwimWorkoutService.fromJson(item as Map<String, dynamic>))
            .toList()
        : <SwimWorkoutService>[];

    return TaraSwimArenaWorkoutDashboardData(
      arenaInfo: arenaJson != null
          ? ArenaInfo.fromJson(arenaJson)
          : const ArenaInfo(
              name: 'Tara Swim Arena Workout Center',
              tagline: 'Elite Aquatic Training & Swim Fitness Programs',
              location: 'Olympic Aquatics Complex, Lane 1-8',
              contact: '+63 912 345 6789',
              totalServices: 6,
            ),
      weeklySummary: summaryJson != null
          ? WeeklySummary.fromJson(summaryJson)
          : WeeklySummary(
              sessionsCompleted: parsedServices.where((s) => s.status.toLowerCase() == 'completed').length,
              targetSessions: parsedServices.isNotEmpty ? parsedServices.length : 5,
              totalDistanceMeters: parsedServices.fold<int>(0, (sum, s) => sum + s.distanceMeters),
              totalDurationMinutes: parsedServices.fold<int>(0, (sum, s) => sum + s.durationMinutes),
            ),
      services: parsedServices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arenaInfo': arenaInfo.toJson(),
      'weeklySummary': weeklySummary.toJson(),
      'services': services.map((s) => s.toJson()).toList(),
      'sessions': services.map((s) => s.toJson()).toList(),
    };
  }
}

// Backward-compatible typedef
typedef WorkoutDashboardData = TaraSwimArenaWorkoutDashboardData;
