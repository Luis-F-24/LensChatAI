import 'package:flutter_dotenv/flutter_dotenv.dart';

final String geminiKey = dotenv.env['GEMINI_API_KEY'] ?? 'CHAVE_PADRAO_GEMINI_NAO_ENCONTRADA';