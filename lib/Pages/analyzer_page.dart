import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/image_analyzer_widget.dart';

class AnalyzerPage extends StatefulWidget {
  final File imageFile;

  const AnalyzerPage({super.key, required this.imageFile});

  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _onRetakePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File newImage = File(pickedFile.path);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AnalyzerPage(imageFile: newImage)),
      );
    } else {
    }
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
              child: ImageAnalyzerWidget(imageFile: widget.imageFile),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onRetakePhoto,
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