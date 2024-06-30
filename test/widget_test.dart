import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:intl/intl.dart'; // Make sure this import is correct

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our calendar title and month are displayed.
    expect(find.text("Calendar"), findsOneWidget);
    expect(find.text(DateFormat('MMMM yyyy').format(DateTime.now())), findsOneWidget);

    // Tap the arrow forward icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();

    // Verify that the first day of the month is displayed as selected.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget); // Assuming MON is the correct first day in your test setup.
  });
}
