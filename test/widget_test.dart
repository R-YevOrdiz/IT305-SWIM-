import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taraswimarenaworkout/tara_swim_arena_workout_page.dart';

void main() {
  testWidgets(
    'Tara Swim Arena Workout page renders Material widgets and services UI',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaraSwimArenaWorkoutPage()));

      expect(find.text('Tara Swim Arena'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );
}
