import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ Importa flutter_dotenv

import 'Pages/home_page.dart'; // ✅ Importa a HomePage

Future<void> solicitarPermissoes() async {
  if (!kIsWeb) {  // ✅ Evita solicitação de permissões no navegador
    var statusCamera = await Permission.camera.status;
    if (!statusCamera.isGranted) {
      await Permission.camera.request();
    }

    var statusArmazenamento = await Permission.storage.status;
    if (!statusArmazenamento.isGranted) {
      await Permission.storage.request();
    }

    var statusMidia = await Permission.photos.status;
    if (!statusMidia.isGranted) {
      await Permission.photos.request();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // ✅ Carrega as variáveis do .env
  await solicitarPermissoes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LensChatAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF372440),
        scaffoldBackgroundColor: const Color(0xFF372440),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF372440),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD1C7B8),
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD1C7B8),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const HomePage(), // ✅ Define HomePage como inicial
    );
  }
}