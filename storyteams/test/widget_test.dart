import 'package:flutter_test/flutter_test.dart';
import 'package:storyteams/main.dart';

void main() {
  testWidgets('StoryTeamsApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StoryTeamsApp());
    expect(find.byType(StoryTeamsApp), findsOneWidget);
  });
}
