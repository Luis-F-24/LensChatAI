import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../config.dart';  // ✅ Importa a chave de configuração

final Logger _logger = Logger();  // ✅ Instância global do Logger

/// Limite máximo de tamanho da imagem: 5MB
const int maxImageSizeInBytes = 5 * 1024 * 1024;

/// Analisa uma imagem utilizando a API do OpenAI.
Future<String?> analyzeImageWithOpenAI(File imageFile) async {
  try {
    // ✅ Verifica o tamanho da imagem antes de enviar.
    final int imageSize = imageFile.lengthSync();
    _logger.i('Tamanho da imagem: $imageSize bytes');

    if (imageSize > maxImageSizeInBytes) {
      _logger.w('Imagem muito grande para análise: $imageSize bytes');
      return 'Imagem muito grande para análise. Por favor, tente com uma imagem menor que 5MB.';
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openAIKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {
            "role": "system",
            "content": "Você é um assistente que descreve imagens de forma concisa."
          },
          {
            "role": "user",
            "content": [
              {"type": "text", "text": "Descreva brevemente esta imagem:"},
              {
                "type": "image_url",
                "image_url": "data:image/jpeg;base64,$base64Image"
              }
            ]
          }
        ],
        "max_tokens": 200
      }),
    );

    _logger.i('Status da resposta: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final content = decoded['choices'][0]['message']['content'];
      _logger.i('Descrição recebida: $content');
      return content;
    } else if (response.statusCode == 429) {
      _logger.w('Quota excedida: ${response.body}');
      return 'Limite de uso da API excedido. Por favor, tente novamente mais tarde ou verifique seus créditos na OpenAI.';
    } else if (response.statusCode == 403) {
      _logger.w('Acesso negado: ${response.body}');
      return 'Acesso à API negado. Verifique se sua chave de API está ativa e se há créditos disponíveis.';
    } else {
      _logger.e('Erro na resposta: ${response.statusCode} - ${response.body}');
      return 'Erro: ${response.statusCode} - ${response.body}';
    }
  } on SocketException catch (e) {
    _logger.w('Sem conexão com a internet: $e');
    return 'Sem conexão com a internet. Por favor, verifique sua conexão e tente novamente.';
  } catch (e, stacktrace) {
    _logger.e('Erro ao enviar imagem: $e', error: e, stackTrace: stacktrace);
    return 'Erro inesperado ao enviar imagem: $e';
  }
}