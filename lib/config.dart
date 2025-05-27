import 'package:flutter_dotenv/flutter_dotenv.dart';

final String openAIKey = dotenv.env['OPENAI_API_KEY'] ?? '';