import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Nanti inisialisasi Local Storage (SharedPrefs/Hive) akan diletakkan di sini.
  
  runApp(
    MultiProvider(
      providers: [
        // Provider kosong sementara agar tidak error saat running TAHAP 1
        Provider<bool>.value(value: true),
      ],
      child: const SwiftTrackApp(),
    ),
  );
}