import 'package:etle_smart_detection/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> bootToLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EtleApp());
    await tester.pump();
    expect(find.text('ETLE Smart Detection'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang kembali'), findsOneWidget);
  }

  testWidgets('aplikasi menampilkan splash lalu login', (tester) async {
    await bootToLogin(tester);
    expect(find.text('Masuk ke akun'), findsOneWidget);
    expect(find.text('Akun demo'), findsOneWidget);
  });

  testWidgets('login demo membuka dashboard dan tab data', (tester) async {
    await bootToLogin(tester);

    await tester.ensureVisible(find.text('Isi otomatis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi otomatis'));
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan Hari Ini'), findsOneWidget);

    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();
    expect(find.text('Data Pelanggaran'), findsOneWidget);
  });
}
