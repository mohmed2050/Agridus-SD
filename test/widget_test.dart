import 'package:flutter_test/flutter_test.dart';
import 'package:agridus_sd/providers/app_provider.dart';
import 'package:agridus_sd/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    final appProvider = AppProvider();
    await tester.pumpWidget(AgridusApp(appProvider: appProvider));
    await tester.pump();
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('التقويم'), findsOneWidget);
  });
}
