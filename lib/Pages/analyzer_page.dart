import 'package:flutter/material.dart';
import 'dart:io';

import '../widgets/image_analyzer_widget.dart'; // importe seu widget de análise de imagem

class AnalyzerPage extends StatefulWidget {
  final File imageFile;
  final VoidCallback onRetakePhoto;

  const AnalyzerPage({super.key, required this.imageFile, required this.onRetakePhoto});

  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
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
          onPressed: widget.onRetakePhoto,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ImageAnalyzerWidget(imageFile: widget.imageFile),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onRetakePhoto,
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
