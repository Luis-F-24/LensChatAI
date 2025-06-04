import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';  // <-- Import do TTS
import '../widgets/image_analyzer_widget.dart';
import 'history_page.dart';
import 'home_page.dart';

class AnalyzerPage extends StatefulWidget {
  final File imageFile;

  const AnalyzerPage({super.key, required this.imageFile});

  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
  // ignore: unused_field
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> ttsStop() async {
    await _flutterTts.stop();
  }

  void _onRetakePhoto() async {
    await ttsStop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HomePage(startWithCamera: true)),
    );
  }

  void _goToHistory() async {
    await ttsStop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
  }

  void _onBack() async {
    await ttsStop();
    Navigator.of(context).pop();
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
          onPressed: _onBack,  // <-- Usar o método com ttsStop
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _goToHistory,  // <-- Usar o método com ttsStop
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ImageAnalyzerWidget(imageFile: widget.imageFile),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onRetakePhoto,  // <-- Usar o método com ttsStop
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
