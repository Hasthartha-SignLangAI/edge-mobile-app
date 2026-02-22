import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hasthaartha_app/services/onnx_servce.dart';

import 'firebase_options.dart';
import 'localdb/isar_db.dart';
import 'screens/splash/logoscreen.dart';

final onnxServiceProvider = Provider<OnnxService>((ref) {
  return OnnxService();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local DB (offline) init
  await IsarDB.open();

  // Firebase init
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  // 🔥 Initialize ONNX Runtime
  final onnxService = OnnxService();

  try {
    await onnxService.init();
    print("✅ ONNX model loaded successfully");
  } catch (e) {
    print("❌ ONNX INIT ERROR: $e");
  }

  runApp(
    ProviderScope(
      overrides: [
        onnxServiceProvider.overrideWithValue(onnxService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hasthaartha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LogoScreen(),
    );
  }
}
