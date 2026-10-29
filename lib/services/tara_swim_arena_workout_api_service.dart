import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/tara_swim_arena_workout_model.dart';
export '../models/tara_swim_arena_workout_model.dart';

enum DataSourceType { httpNetwork, localAsset, fallback }

class FetchResult {
  final TaraSwimArenaWorkoutDashboardData data;
  final DataSourceType sourceType;
  final String? sourceUrl;
  final String? errorMessage;
  final int? statusCode;

  const FetchResult({
    required this.data,
    required this.sourceType,
    this.sourceUrl,
    this.errorMessage,
    this.statusCode,
  });
}

class TaraSwimArenaWorkoutApiService {
  /// Default Live HTTP REST API Endpoint hosting Tara Swim Arena Workout services/products
  static const String defaultHttpEndpoint = 'https://dpaste.com/HH29BGBN6.txt';

  /// User configurable custom API URL
  static String? customApiUrl;

  /// ============================================================
  /// 1. HTTP GET REQUEST EXECUTION
  /// Performs an asynchronous HTTP GET request using package:http
  /// ============================================================
  static Future<http.Response> executeHttpGetRequest(String url) async {
    final uri = Uri.parse(url);
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json, text/plain',
        'User-Agent': 'TaraSwimArenaWorkoutApp/1.0',
      },
    ).timeout(const Duration(seconds: 12));
  }

  /// ============================================================
  /// 2. JSON ARRAY TO PRODUCT MAPPING
  /// Parses decoded JSON payload and converts JSON Array to `List<Product>`
  /// ============================================================
  static List<Product> mapJsonArrayToProducts(dynamic jsonPayload) {
    if (jsonPayload is List) {
      return jsonPayload
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (jsonPayload is Map<String, dynamic>) {
      final list = (jsonPayload['services'] ??
          jsonPayload['products'] ??
          jsonPayload['sessions']) as List<dynamic>?;
      if (list != null) {
        return list
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return <Product>[];
  }

  /// Consumes REST API via HTTP GET and maps JSON array to dashboard & product data
  static Future<TaraSwimArenaWorkoutDashboardData> fetchWorkoutsFromHttp(String url) async {
    final response = await executeHttpGetRequest(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        return TaraSwimArenaWorkoutDashboardData.fromJson(decoded);
      } else if (decoded is List) {
        final products = mapJsonArrayToProducts(decoded);
        return TaraSwimArenaWorkoutDashboardData(
          arenaInfo: const ArenaInfo(
            name: 'Tara Swim Arena Workout Center',
            tagline: 'Elite Aquatic Training & Swim Fitness Programs',
            location: 'Olympic Aquatics Complex, Lane 1-8',
            contact: '+63 912 345 6789',
            totalServices: 6,
          ),
          weeklySummary: WeeklySummary(
            sessionsCompleted: products.where((s) => s.status.toLowerCase() == 'completed').length,
            targetSessions: products.isNotEmpty ? products.length : 5,
            totalDistanceMeters: products.fold<int>(0, (sum, s) => sum + s.distanceMeters),
            totalDurationMinutes: products.fold<int>(0, (sum, s) => sum + s.durationMinutes),
          ),
          services: products,
        );
      } else {
        throw const FormatException('Unexpected JSON payload format');
      }
    } else {
      throw Exception('HTTP GET Failed (Status ${response.statusCode}): ${response.reasonPhrase}');
    }
  }

  /// Loads fallback local JSON asset
  static Future<TaraSwimArenaWorkoutDashboardData> fetchWorkoutsFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/workouts.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return TaraSwimArenaWorkoutDashboardData.fromJson(decoded);
    } catch (_) {
      final jsonString = await rootBundle.loadString('workouts.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return TaraSwimArenaWorkoutDashboardData.fromJson(decoded);
    }
  }

  /// Primary API consumer: Queries remote HTTP REST API endpoint via GET request,
  /// with automatic fallback to bundled JSON asset if network is unreachable.
  static Future<FetchResult> fetchDashboardData({String? urlOverride}) async {
    final targetUrl = (urlOverride != null && urlOverride.trim().isNotEmpty)
        ? urlOverride.trim()
        : (customApiUrl != null && customApiUrl!.trim().isNotEmpty)
            ? customApiUrl!.trim()
            : defaultHttpEndpoint;

    try {
      final data = await fetchWorkoutsFromHttp(targetUrl);
      return FetchResult(
        data: data,
        sourceType: DataSourceType.httpNetwork,
        sourceUrl: targetUrl,
        statusCode: 200,
      );
    } catch (httpError) {
      debugPrint('HTTP GET Request failed: $httpError. Falling back to local JSON asset.');
      try {
        final assetData = await fetchWorkoutsFromAsset();
        return FetchResult(
          data: assetData,
          sourceType: DataSourceType.localAsset,
          sourceUrl: targetUrl,
          errorMessage: httpError.toString(),
        );
      } catch (assetError) {
        debugPrint('Local asset fallback also failed: $assetError');
        rethrow;
      }
    }
  }
}

// Backward compatibility alias
typedef WorkoutApiService = TaraSwimArenaWorkoutApiService;
