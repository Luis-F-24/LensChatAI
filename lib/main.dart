import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ✅ Importação do Hive
import 'models/history_item.dart'; // ✅ Importação do modelo para registrar o adapter
import 'Pages/home_page.dart';

List<CameraDescription> cameras = [];
final Logger _logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // ✅ Inicialização do Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryItemAdapter());
  await Hive.openBox<HistoryItem>('history');

  try {
    cameras = await availableCameras();
    _logger.i('Câmeras disponíveis (main.dart): ${cameras.length} câmera(s) encontrada(s).');
    if (cameras.isNotEmpty) {
      _logger.d('Primeira câmera: ${cameras.first.name}, ${cameras.first.lensDirection}');
    }
  } on CameraException catch (e) {
    _logger.e('Erro ao inicializar câmeras em main.dart: $e');
  } catch (e, stacktrace) {
    _logger.e('Erro inesperado em main.dart ao buscar câmeras: $e', error: e, stackTrace: stacktrace);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lens Chat AI',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
