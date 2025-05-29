import 'package:flutter/material.dart';
import 'dart:io';

import '../widgets/image_analyzer_widget.dart';
import 'history_page.dart';
import 'home_page.dart';

class AnalyzerPage extends StatelessWidget {
  final File imageFile;

  const AnalyzerPage({super.key, required this.imageFile});

  void _retakePhoto(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryPage()),
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
        child: ImageAnalyzerWidget(imageFile: imageFile),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _retakePhoto(context),
            backgroundColor: const Color(0xFFD1C7B8),
            label: const Text(
              'Tirar outra foto',
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(Icons.camera_alt, color: Colors.black),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () => _openHistory(context),
            backgroundColor: const Color(0xFFD1C7B8),
            label: const Text(
              'Ver Histórico',
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(Icons.history, color: Colors.black),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
