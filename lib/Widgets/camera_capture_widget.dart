import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class CameraCaptureWidget extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraCaptureWidget({super.key, required this.onImageCaptured});

  @override
  _CameraCaptureWidgetState createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget> {
  CameraController? _controller;
  bool _isCameraReady = false;
  String? _errorMessage;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhuma câmera disponível.';
        });
        _logger.e(_errorMessage);
        return;
      }

      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
      });

      _logger.i('Câmera inicializada com sucesso');
    } catch (e, stacktrace) {
      setState(() {
        _errorMessage = 'Erro ao inicializar a câmera.';
      });
      _logger.e(_errorMessage, error: e, stackTrace: stacktrace);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _logger.w('Controller não está inicializado');
      return;
    }

    try {
      final image = await _controller!.takePicture();
      _logger.i('Imagem capturada: ${image.path}');
      widget.onImageCaptured(File(image.path));
    } catch (e, stacktrace) {
      _logger.e('Erro ao capturar foto', error: e, stackTrace: stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao capturar a foto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_isCameraReady || _controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Inicializando a câmera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CameraPreview(_controller!),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            tooltip: 'Capturar Foto',
            onPressed: _capturePhoto,
            child: const Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }
}