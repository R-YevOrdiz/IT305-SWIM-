import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:taraswimarenaworkout/models/workout.dart';

void main() {
  group('Workout JSON Deserialization Tests', () {
    const rawJson = '''
    {
      "weeklySummary": {
        "sessionsCompleted": 3,
        "targetSessions": 5,
        "totalDistanceMeters": 5400,
        "totalDurationMinutes": 135
      },
      "sessions": [
        {
          "id": "w1",
          "title": "Morning Sprint Set",
          "durationMinutes": 45,
          "distanceMeters": 1800,
          "status": "Completed",
          "category": "Sprint",
          "date": "Today, 6:30 AM",
          "icon": "timer"
        },
        {
          "id": "w2",
          "title": "Technique Focus",
          "durationMinutes": 30,
          "distanceMeters": 1200,
          "status": "Planned",
          "category": "Technique",
          "date": "Tomorrow, 5:00 PM",
          "icon": "speed"
        }
      ]
    }
    ''';

    test('Parses WorkoutDashboardData from JSON correctly', () {
      final decoded = json.decode(rawJson) as Map<String, dynamic>;
      final dashboardData = WorkoutDashboardData.fromJson(decoded);

      expect(dashboardData.weeklySummary.sessionsCompleted, equals(3));
      expect(dashboardData.weeklySummary.targetSessions, equals(5));
      expect(dashboardData.weeklySummary.totalDistanceMeters, equals(5400));
      expect(dashboardData.weeklySummary.totalDurationMinutes, equals(135));

      expect(dashboardData.sessions.length, equals(2));

      final first = dashboardData.sessions[0];
      expect(first.id, equals('w1'));
      expect(first.title, equals('Morning Sprint Set'));
      expect(first.durationMinutes, equals(45));
      expect(first.distanceMeters, equals(1800));
      expect(first.status, equals('Completed'));
      expect(first.category, equals('Sprint'));
      expect(first.icon, equals('timer'));

      final second = dashboardData.sessions[1];
      expect(second.id, equals('w2'));
      expect(second.title, equals('Technique Focus'));
      expect(second.status, equals('Planned'));
    });

    test('WorkoutSession serializes back to JSON correctly', () {
      const session = WorkoutSession(
        id: 'w99',
        title: 'Endurance Swim',
        durationMinutes: 60,
        distanceMeters: 3000,
        status: 'Planned',
        category: 'Endurance',
        date: 'Sunday, 8:00 AM',
        icon: 'pool',
      );

      final jsonMap = session.toJson();
      expect(jsonMap['id'], equals('w99'));
      expect(jsonMap['distanceMeters'], equals(3000));
      expect(jsonMap['category'], equals('Endurance'));
    });
  });
}
