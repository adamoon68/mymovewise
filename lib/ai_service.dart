import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mymovewiseapp/myconfig.dart';

class AIService {
  final GenerativeModel _model;

  AIService()
    : _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: MyConfig.geminiApiKey,
      );

  Future<String> getRecommendation(String userInput) async {
    try {
      final content = [
        Content.text("${MyConfig.systemInstruction}\nUser Status: $userInput"),
      ];
      final response = await _model.generateContent(content);
      return response.text ??
          "I'm not sure what to recommend for that. Try again!";
    } catch (e) {
      return "Error connecting to MoveWise AI: $e";
    }
  }
}
