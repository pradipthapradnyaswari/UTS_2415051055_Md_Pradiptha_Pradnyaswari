import 'package:flutter_test/flutter_test.dart';
import 'package:finote/app.dart';

void main() {
  testWidgets('Finote app displays correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FinoteApp());

    expect(find.text('Finote'), findsOneWidget);
  });
}