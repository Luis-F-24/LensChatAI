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
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
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
        _logger.e('Nenhuma câmera disponível');
        return;
      }

      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,  // Como só quer foto, pode desligar áudio
      );

      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      if (mounted) setState(() {});
      _logger.i('Câmera inicializada com sucesso');
    } catch (e, stacktrace) {
      _logger.e('Erro ao inicializar a câmera', error: e, stackTrace: stacktrace);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      if (_initializeControllerFuture == null) {
        _logger.w('Câmera não inicializada ainda');
        return;
      }

      await _initializeControllerFuture;

      if (!_controller.value.isInitialized) {
        _logger.w('Controller não está inicializado');
        return;
      }

      final image = await _controller.takePicture();

      _logger.i('Imagem capturada: ${image.path}');
      widget.onImageCaptured(File(image.path));
    } catch (e, stacktrace) {
      _logger.e('Erro ao capturar foto', error: e, stackTrace: stacktrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!_controller.value.isInitialized) {
            return const Center(child: Text('Falha ao inicializar câmera'));
          }
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CameraPreview(_controller),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  onPressed: _capturePhoto,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao inicializar câmera: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
