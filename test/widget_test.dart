import 'package:flutter_test/flutter_test.dart';
import 'package:voxy/main.dart';

void main() {
  testWidgets('VoxyApp smoke test & UI presence', (WidgetTester tester) async {
    await tester.pumpWidget(const VoxyApp());

    // Expect brand name and connection label
    expect(find.text('VOXY'), findsOneWidget);
    expect(find.text('DISCONNECTED'), findsOneWidget);
    expect(find.text('Tap to Connect'), findsOneWidget);
  });
}

