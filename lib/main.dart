import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

import 'Pages/home_page.dart'; // Onde CameraCaptureWidget é chamado

List<CameraDescription> cameras = []; // Variável global para armazenar as câmeras
final Logger _logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Carrega as variáveis de ambiente (CRUCIAL para chaves)
  await dotenv.load(fileName: ".env");

  // 2. Inicializa as câmeras ANTES de rodar o aplicativo
  try {
    cameras = await availableCameras();
    _logger.i('Câmeras disponíveis (main.dart): ${cameras.length} câmera(s) encontrada(s).');
    if (cameras.isNotEmpty) {
      _logger.d('Primeira câmera: ${cameras.first.name}, ${cameras.first.lensDirection}');
    }
  } on CameraException catch (e) {
    _logger.e('Erro ao inicializar câmeras em main.dart: $e');
    // Em caso de erro grave aqui, você pode optar por mostrar um AlertDialog
    // ou apenas logar e continuar, permitindo que o CameraCaptureWidget lide com a lista vazia.
  } catch (e, stacktrace) {
    _logger.e('Erro inesperado em main.dart ao buscar câmeras: $e', error: e, stackTrace: stacktrace);
  }

  // AQUI: A lista 'cameras' global deve estar preenchida (ou vazia se não encontrou)
  // SOMENTE AGORA executamos o aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // É importante passar a lista de câmeras do main.dart para o HomePage
    // e, consequentemente, para o CameraCaptureWidget
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lens Chat AI',
      theme: ThemeData.dark(),
      // Certifique-se de que o HomePage está recebendo a lista de câmeras
      home: HomePage(), // Ou HomePage(availableCameras: cameras), se você modificou o HomePage
    );
  }
}