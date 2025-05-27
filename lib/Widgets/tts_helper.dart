import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  final FlutterTts _flutterTts = FlutterTts();

  TtsHelper() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("pt-BR");  // Português do Brasil
    await _flutterTts.setSpeechRate(0.5);    // Velocidade normal
    await _flutterTts.setPitch(1.0);         // Tom normal
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.stop();    // Para qualquer fala anterior antes de falar nova
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
