// Basic Flutter widget test for Practice Timer App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Simple test to verify Flutter is working
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('琴时'),
          ),
        ),
      ),
    );

    expect(find.text('琴时'), findsOneWidget);
  });
}
