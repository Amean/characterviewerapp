// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:search_page/search_page.dart';
import 'package:mockito/mockito.dart';

import 'package:viewerapp/main.dart';

void main() {
  testWidgets('Search Screen Test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // when().thenAnswer((_) async => );
    // ran out of time

    await tester.pumpWidget(Sizer(
      builder: (context, orientation, deviceType) => const MaterialApp(
        home: SearchScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(AppBar));
    await tester.ensureVisible(find.byType(FloatingActionButton));
    await tester
        .ensureVisible(find.byType(FutureBuilder<List<SimpsonsCharacter>>));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    tester.ensureVisible(find.byType(SearchPage));

    if (SizerUtil.deviceType == DeviceType.mobile) {
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(DetailsScreen));
    }
  });
}
