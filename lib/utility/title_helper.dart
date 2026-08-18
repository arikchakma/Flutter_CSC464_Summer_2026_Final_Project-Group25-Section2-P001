import 'package:firebase_ai/firebase_ai.dart';

import 'package:final_project/utility/constant.dart';

class TitleHelper {
  static Future<String> generateChatTitle(
    String language,
    String message,
  ) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: AppConstant.geminiModel,
        systemInstruction: Content.system(
          AppConstant.titleInstruction(language),
        ),
        generationConfig: GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 32,
          thinkingConfig: ThinkingConfig.withThinkingLevel(
            ThinkingLevel.minimal,
          ),
        ),
      );

      final response = await model.generateContent([Content.text(message)]);

      return (response.text ?? '').trim();
    } catch (_) {
      return '';
    }
  }
}
