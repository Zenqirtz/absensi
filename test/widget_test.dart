// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AbsenEaseApp());

    expect(find.text('AbsenEase'), findsOneWidget);
  });
}
