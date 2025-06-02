import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../config.dart';

final Logger _logger = Logger();

const int maxImageSizeInBytes = 4 * 1024 * 1024; // 4MB

Future<String?> analyzeImageWithGemini(File imageFile) async {
  try {
    final int imageSize = imageFile.lengthSync();
    _logger.i('Tamanho da imagem: $imageSize bytes');

    if (imageSize > maxImageSizeInBytes) {
      _logger.w('Imagem muito grande para análise: $imageSize bytes');
      return 'Imagem muito grande para análise. Por favor, tente com uma imagem menor que 4MB.';
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Você é um assistente de inteligência artificial otimizado para descrever o conteúdo de imagens de forma clara, concisa e precisa. Suas respostas devem ser sempre em português brasileiro. Foque em identificar objetos, pessoas, ações e o ambiente principal da imagem."},
              {"text": "Descreva a imagem que você vai receber. Crie uma descrição direta, com 1 a 3 frases, destacando os elementos visuais mais relevantes e o contexto geral."},
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "maxOutputTokens": 150,
          "temperature": 0.4,
          "topP": 1.0,
          "topK": 32,
        }
      }),
    );

    _logger.i('Status da resposta: ${response.statusCode}');
    _logger.d('Corpo da resposta: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['candidates'] != null && decoded['candidates'].isNotEmpty) {
        final content = decoded['candidates'][0]['content']['parts'][0]['text'];
        _logger.i('Descrição recebida: $content');
        return content;
      } else {
        _logger.w('Resposta da API não contém "candidates" ou "content".');
        return 'Não foi possível gerar uma descrição para a imagem.';
      }
    } else if (response.statusCode == 400) {
      _logger.w('Requisição inválida (Erro do cliente): ${response.body}');
      return 'Erro na requisição (400): ${response.body}. Verifique o formato da sua requisição ou a imagem.';
    } else if (response.statusCode == 403) {
      _logger.w('Acesso negado (Chave inválida/problema de permissão): ${response.body}');
      return 'Acesso à API negado (403). Verifique se sua chave de API está correta e tem as permissões necessárias.';
    } else if (response.statusCode == 429) {
      _logger.w('Quota excedida: ${response.body}');
      return 'Limite de uso da API excedido (429). Por favor, tente novamente mais tarde ou verifique seus créditos no Google Cloud.';
    } else if (response.statusCode >= 500) { // Erros de servidor
      _logger.e('Erro interno do servidor (${response.statusCode}): ${response.body}');
      return 'Erro interno do servidor (${response.statusCode}). Por favor, tente novamente mais tarde.';
    } else {
      _logger.e('Erro inesperado na resposta: ${response.statusCode} - ${response.body}');
      return 'Erro inesperado: ${response.statusCode} - ${response.body}';
    }
  } on SocketException catch (e) {
    _logger.w('Sem conexão com a internet: $e');
    return 'Sem conexão com a internet. Por favor, verifique sua conexão e tente novamente.';
  } catch (e, stacktrace) {
    _logger.e('Erro inesperado ao enviar imagem: $e', error: e, stackTrace: stacktrace);
    return 'Erro inesperado ao enviar imagem: $e';
  }
}