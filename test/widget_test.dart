// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smlmarket/main.dart';

void main() {
  testWidgets('Product search app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmlMarketApp());

    // Verify that our search app has the correct title.
    expect(find.text('SML Market'), findsOneWidget);
    expect(find.text('ค้นหาสินค้าที่คุณต้องการ'), findsOneWidget);

    // Verify search field exists
    expect(find.byType(TextField), findsOneWidget);
  });
}
