import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swift_track/app.dart';

void main() {
  testWidgets('Memverifikasi Splash Screen dan Entry Point', (WidgetTester tester) async {
    // Build aplikasi kita dan memicu frame.
    // Kita WAJIB membungkusnya dengan MultiProvider yang sama persis seperti di main.dart
    // untuk mencegah error "ProviderNotFoundException".
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<bool>.value(value: true), // Dummy provider tahap 1
        ],
        child: const SwiftTrackApp(),
      ),
    );

    // Verifikasi bahwa teks pada Splash Screen kita berhasil di-render di layar
    expect(find.text('SwiftTrack'), findsOneWidget);
    expect(find.text('Live GPS & Courier Monitor'), findsOneWidget);
    
    // Opsional: Membiarkan animasi widget tree selesai agar tidak ada timer yang menggantung (pending timer)
    await tester.pumpAndSettle();
  });
}