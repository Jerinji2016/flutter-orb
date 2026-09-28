import 'package:flutter_test/flutter_test.dart';
import 'package:voice_orb_example/main.dart';

void main() {
  testWidgets('VoiceOrbExampleApp mounts successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VoiceOrbExampleApp());
    expect(find.text('FLUTTER ORB'), findsOneWidget);
  });
}
