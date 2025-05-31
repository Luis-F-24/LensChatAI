import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ Importe permission_handler aqui

class CameraCaptureWidget extends StatefulWidget {
  final Function(File) onImageCaptured;
  final List<CameraDescription> availableCameras; // ✅ Adicione este parâmetro

  const CameraCaptureWidget({
    super.key,
    required this.onImageCaptured,
    required this.availableCameras, // ✅ Requer a lista de câmeras
  });

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
    // ✅ PASSO CRUCIAL: Solicitar permissões em tempo de execução
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      setState(() {
        _errorMessage = 'Permissão da câmera ou microfone negada. Por favor, conceda as permissões nas configurações do aplicativo para usar a câmera.';
      });
      _logger.e(_errorMessage);
      return; // Impede a inicialização da câmera se a permissão for negada
    }

    if (cameraStatus.isPermanentlyDenied || microphoneStatus.isPermanentlyDenied) {
      setState(() {
        _errorMessage = 'Permissão da câmera ou microfone negada permanentemente. Vá para as configurações do aplicativo para habilitar.';
      });
      _logger.e(_errorMessage);
      openAppSettings(); // Abre as configurações do aplicativo para o usuário habilitar manualmente
      return; // Impede a inicialização da câmera se a permissão for negada permanentemente
    }

    // Apenas se as permissões foram concedidas, proceda com a inicialização da câmera
    try {
      final cameras = widget.availableCameras;

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhuma câmera disponível no dispositivo.';
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

      await _controller?.initialize();

      // Verifica se o widget ainda está montado antes de chamar setState
      if (!mounted || _controller == null || !_controller!.value.isInitialized) {
        _logger.w('Controlador da câmera não inicializado ou widget desmontado.');
        return;
      }

      setState(() {
        _isCameraReady = true;
      });

      _logger.i('Câmera inicializada com sucesso');
    } catch (e, stacktrace) {
      setState(() {
        _errorMessage = 'Erro ao inicializar a câmera. Verifique as permissões ou tente novamente: ${e.toString()}'; // Adicione a mensagem de erro para depuração
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
      _logger.w('Controller não está inicializado para captura.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Câmera não está pronta.')),
        );
      }
      return;
    }

    try {
      final image = await _controller!.takePicture();

      if (!mounted) return;

      _logger.i('Imagem capturada: ${image.path}');
      widget.onImageCaptured(File(image.path));
    } catch (e, stacktrace) {
      _logger.e('Erro ao capturar foto', error: e, stackTrace: stacktrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao capturar a foto')),
        );
      }
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