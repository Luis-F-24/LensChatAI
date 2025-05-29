import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widgets/history_widget.dart';
import '../widgets/history_entry.dart';
import '../widgets/camera_capture_widget.dart';
import 'dart:io';
import 'analyzer_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _showCamera = false;
  bool _isClearing = false;

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente apagar todo o histórico? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isClearing = true;
    });

    final box = Hive.box<HistoryEntry>('history');

    for (int i = 0; i < box.length; i++) {
      final entry = box.getAt(i);
      if (entry != null) {
        final file = File(entry.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    await box.clear();

    setState(() {
      _isClearing = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Histórico limpo com sucesso!')),
    );
  }

  void _onImageCaptured(File image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzerPage(imageFile: image),
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
    return Scaffold(
      backgroundColor: const Color(0xFF372440),
      appBar: AppBar(
        backgroundColor: const Color(0xFF372440),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Histórico de Análises',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Limpar histórico',
            onPressed: _isClearing ? null : _clearHistory,
          ),
        ],
      ),
      body: _showCamera
          ? CameraCaptureWidget(onImageCaptured: _onImageCaptured)
          : _isClearing
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: HistoryWidget()),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                  ],
                ),
    );
  }
}