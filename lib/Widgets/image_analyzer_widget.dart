import 'package:flutter/material.dart';
import 'dart:io';

import 'openai_service.dart';
import 'tts_helper.dart';

class ImageAnalyzerWidget extends StatefulWidget {
  final File imageFile;

  const ImageAnalyzerWidget({super.key, required this.imageFile});

  @override
  _ImageAnalyzerWidgetState createState() => _ImageAnalyzerWidgetState();
}

class _ImageAnalyzerWidgetState extends State<ImageAnalyzerWidget> {
  String? _description;
  bool _isLoading = false;
  bool _analyzed = false;
  final TtsHelper _ttsHelper = TtsHelper();

  @override
  void dispose() {
    _ttsHelper.stop();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (_analyzed) return;  // ✅ Evita múltiplas execuções
    setState(() {
      _isLoading = true;
    });

    final description = await analyzeImageWithOpenAI(widget.imageFile);

    setState(() {
      _description = description ?? 'Não foi possível obter a descrição.';
      _isLoading = false;
      _analyzed = true;
    });

    if (description != null) {
      await _ttsHelper.speak(description);
    }
  }

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.file(
          widget.imageFile,
          fit: BoxFit.contain,  // ✅ Melhor adaptação
          height: 300,
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _description ?? 'Analisando imagem...',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,  // ✅ Melhor visual
                ),
              ),
        if (!_isLoading && _description != null && _description == 'Não foi possível obter a descrição.')
          ElevatedButton(
            onPressed: () {
              setState(() {
                _analyzed = false;  // ✅ Permite nova tentativa
              });
              _analyzeImage();
            },
            child: const Text('Tentar novamente'),
          ),
      ],
    );
  }
}