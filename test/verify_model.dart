// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:taraswimarenaworkout/models/tara_swim_arena_workout_model.dart';

void main() {
  print('Testing JSON parsing with workouts.json...');
  final file = File('workouts.json');
  if (!file.existsSync()) {
    print('Error: workouts.json does not exist');
    exit(1);
  }

  final content = file.readAsStringSync();
  final Map<String, dynamic> jsonMap = json.decode(content);
  final dashboardData = TaraSwimArenaWorkoutDashboardData.fromJson(jsonMap);

  print('Arena: ${dashboardData.arenaInfo.name}');
  print('Weekly summary: ${dashboardData.weeklySummary.sessionsCompleted}/${dashboardData.weeklySummary.targetSessions} completed');
  print('Total distance: ${dashboardData.weeklySummary.totalDistanceMeters}m');
  print('Loaded ${dashboardData.services.length} services/products:');

  for (final s in dashboardData.services) {
    print(' - [${s.status}] ${s.title} (₱${s.price.toStringAsFixed(2)}, ${s.durationMinutes} min, ${s.distanceMeters}m, coach: ${s.coach})');
  }

  assert(dashboardData.services.isNotEmpty);
  assert(dashboardData.weeklySummary.sessionsCompleted == 3);
  print('\nAll model and JSON validations PASSED successfully!');
}
