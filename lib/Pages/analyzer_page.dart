import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/image_analyzer_widget.dart';
import 'home_page.dart';

class AnalyzerPage extends StatelessWidget {
  final File imageFile;

  const AnalyzerPage({super.key, required this.imageFile});

  void _onRetakePhoto(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
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
          'LensChatAI - Análise',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ImageAnalyzerWidget(imageFile: imageFile),
            ),
            const SizedBox(height: 80),  // Mantém espaço para o FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onRetakePhoto(context),
        backgroundColor: const Color(0xFFD1C7B8),
        label: const Text(
          'Tirar outra foto',
          style: TextStyle(color: Colors.black),
        ),
        icon: const Icon(Icons.camera_alt, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
