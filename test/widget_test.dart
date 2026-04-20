import 'package:flutter_test/flutter_test.dart';

import 'package:vinma_app/main.dart' as app;

void main() {
  testWidgets('빈마 앱 셸을 렌더링한다', (tester) async {
    app.main();
    await tester.pump();

    expect(find.text('빈티지'), findsOneWidget);
    expect(find.text('마켓'), findsOneWidget);
    expect(find.text('8개 컬렉션'), findsOneWidget);
    expect(find.text('크로켓앤존스 첼시 옥스포드 UK8'), findsOneWidget);
  });
}