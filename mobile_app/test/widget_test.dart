import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('CivicSatireApp renders NationalFeedScreen cleanly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: CivicSatireApp(),
      ),
    );

    // Verify that the initial screen header is displayed.
    expect(find.text('The National Feed'), findsOneWidget);
  });
}
