import 'package:flutter_dotenv/flutter_dotenv.dart';

// As chaves da API são carregadas do .env através do flutter_dotenv
// Certifique-se de que dotenv.load() foi chamado em main.dart antes de acessar estas variáveis.

final String geminiKey = dotenv.env['GEMINI_API_KEY'] ?? 'CHAVE_PADRAO_GEMINI_NAO_ENCONTRADA';