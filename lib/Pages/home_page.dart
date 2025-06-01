import 'package:flutter/material.dart';
import '../widgets/camera_capture_widget.dart';
import 'dart:io';
import '../main.dart' as app_main;
import 'analyzer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCamera = false;

  void _onImageCaptured(File image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzerPage(
          imageFile: image,
        ),
      ),
    );
    setState(() {
      _showCamera = false;
    });
  }

  void _openCamera() {
    setState(() {
      _showCamera = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (app_main.cameras.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF372440),
        appBar: AppBar(
          backgroundColor: const Color(0xFF372440),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'LensChatAI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Não foi possível encontrar nenhuma câmera disponível. Por favor, verifique as permissões do aplicativo e reinicie-o.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF372440),
      appBar: AppBar(
        backgroundColor: const Color(0xFF372440),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LensChatAI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _showCamera
          ? CameraCaptureWidget(
              onImageCaptured: _onImageCaptured,
              availableCameras: app_main.cameras,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _openCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD1C7B8),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Abrir Câmera',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
