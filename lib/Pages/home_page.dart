import 'package:flutter/material.dart';
import '../widgets/camera_capture_widget.dart'; // seu widget de câmera
import 'dart:io';

import 'analyzer_page.dart'; // importe a página de análise

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCamera = false;

  void _onImageCaptured(File image) {
    // Navega para a página de análise passando a imagem e callback para voltar
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzerPage(
          imageFile: image,
          onRetakePhoto: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    // Fecha a câmera para evitar manter na pilha (opcional)
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
          ? CameraCaptureWidget(onImageCaptured: _onImageCaptured)
          : Center(
              child: ElevatedButton(
                onPressed: _openCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1C7B8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
            ),
    );
  }
}