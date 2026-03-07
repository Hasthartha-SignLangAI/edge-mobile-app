import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hasthaartha_app/services/ble_pipeline_service.dart';
import 'package:hasthaartha_app/services/onnx_servce.dart';
import 'package:hasthaartha_app/services/realtime_engine.dart';

import 'firebase_options.dart';
import 'localdb/isar_db.dart';
import 'screens/splash/logoscreen.dart';
import 'package:hasthaartha_app/services/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onnxServiceProvider = Provider<OnnxService>((ref) {
  throw UnimplementedError("OnnxService must be overridden in main()");
});

final realtimeEngineProvider = Provider<RealtimeGestureEngine>((ref) {
  final onnx = ref.read(onnxServiceProvider);
  return RealtimeGestureEngine(onnx);
});

final blePipelineProvider = Provider<BlePipelineService>((ref) {
  final onnx = ref.read(onnxServiceProvider);
  final engine = ref.read(realtimeEngineProvider);

  return BlePipelineService(onnx: onnx, engine: engine);
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local DB (offline) init
  await IsarDB.open();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔥 Initialize ONNX Runtime
  final onnxService = OnnxService();

  try {
    await onnxService.init();
    print("✅ ONNX model loaded successfully");
  } catch (e) {
    print("❌ ONNX INIT ERROR: $e");
  }

  // Check if user has seen splash
  final prefs = await SharedPreferences.getInstance();
  final hasSeenSplash = prefs.getBool('hasSeenSplash') ?? false;

  runApp(
    ProviderScope(
      overrides: [onnxServiceProvider.overrideWithValue(onnxService)],
      child: MyApp(hasSeenSplash: hasSeenSplash),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenSplash;

  const MyApp({super.key, required this.hasSeenSplash});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hasthaartha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: hasSeenSplash ? const AuthGate() : const LogoScreen(),
    );
  }
}
