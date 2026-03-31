import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiori/main.dart';

void main() {
  testWidgets('ShioriApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShioriApp()));
    await tester.pump();
    expect(find.byType(ShioriApp), findsOneWidget);
  });
}
