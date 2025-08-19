// This is a basic Flutter widget test for the Flutter System Check app.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ping/main.dart';

void main() {
  testWidgets('Flutter System Check app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlutterPingApp());

    // Verify that our app loads with the main title
    expect(find.text('Flutter System Check'), findsOneWidget);
    expect(find.text('Run Checks'), findsOneWidget);
  });
}
