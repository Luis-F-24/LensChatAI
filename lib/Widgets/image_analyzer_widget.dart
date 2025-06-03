import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import '../services/api_service.dart';
import '../services/tts_helper.dart';
import '../services/history_service.dart';

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
  final HistoryService _historyService = HistoryService();

  @override
  void dispose() {
    _ttsHelper.stop();
    super.dispose();
  }

  /// ✅ Função para salvar a imagem permanentemente
  Future<String> saveImagePermanently(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<void> _analyzeImage() async {
    if (_analyzed) return;

    setState(() {
      _isLoading = true;
    });

    final description = await analyzeImageWithGemini(widget.imageFile);

    setState(() {
      _description = description ?? 'Não foi possível obter a descrição.';
      _isLoading = false;
      _analyzed = true;
    });

    if (description != null) {
      await _ttsHelper.speak(description);

      // ✅ Salvar imagem em local permanente
      final savedImagePath = await saveImagePermanently(widget.imageFile);

      // ✅ Salvar no histórico com o novo caminho
      await _historyService.addToHistory(
        savedImagePath,
        description,
      );
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
          fit: BoxFit.contain,
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
                  textAlign: TextAlign.center,
                ),
              ),
        if (!_isLoading &&
            _description != null &&
            _description == 'Não foi possível obter a descrição.')
          ElevatedButton(
            onPressed: () {
              setState(() {
                _analyzed = false;
              });
              _analyzeImage();
            },
            child: const Text('Tentar novamente'),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_description != null) {
              _ttsHelper.speak(_description!);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD1C7B8),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Ouvir novamente',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}