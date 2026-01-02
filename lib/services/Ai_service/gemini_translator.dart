import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiTranslator {
  static const String apiKey =
      "AIzaSyAQHLMnLAznmgEILlmrqaeDbjIId3WfOR0";

  static Future<String> translateToEnglish(String message) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final prompt =
          "Translate this Roman Urdu to English. Return ONLY the translated text: $message";
      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);

      if (response.text != null) {
        return response.text!.trim();
      } else {
        return "No response from Gemini";
      }
    } catch (e) {
      print("❌ Package Error: $e");
      return "Error: $e";
    }
  }
}
