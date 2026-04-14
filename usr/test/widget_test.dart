import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:couldai_user_app/main.dart';

void main() {
  testWidgets('Spin and Win smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our title is present.
    expect(find.text('Spin and Win 200 Rs'), findsOneWidget);
    expect(find.text('SPIN'), findsOneWidget);
  });
}
