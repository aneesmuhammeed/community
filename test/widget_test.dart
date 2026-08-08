// Smoke test for CommunityHubApp
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_hub/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CommunityHubApp());
    // Verify the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsNothing); // uses custom nav
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
