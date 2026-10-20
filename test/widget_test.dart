import 'package:flutter_test/flutter_test.dart';
import 'package:awake/main.dart';

void main() {
  testWidgets('App loads browse page', (WidgetTester tester) async {
    await tester.pumpWidget(const AwakeApp());
    expect(find.text('Good Morning'), findsOneWidget);
  });
}
