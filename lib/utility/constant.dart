import 'package:final_project/models/language_model.dart';

class AppConstant {
  static const String geminiModel = 'gemini-3.5-flash-lite';

  static const String usersCollection = 'users';

  static const String chatsCollection = 'chats';

  static const String messagesCollection = 'messages';

  static const String senderUser = 'user';

  static const String senderAi = 'ai';

  static const List<Language> supportedLanguages = [
    Language(name: 'Bangla', flag: '🇧🇩'),
    Language(name: 'Spanish', flag: '🇪🇸'),
    Language(name: 'French', flag: '🇫🇷'),
    Language(name: 'German', flag: '🇩🇪'),
    Language(name: 'Italian', flag: '🇮🇹'),
    Language(name: 'Portuguese', flag: '🇵🇹'),
    Language(name: 'Japanese', flag: '🇯🇵'),
    Language(name: 'Korean', flag: '🇰🇷'),
    Language(name: 'Chinese', flag: '🇨🇳'),
    Language(name: 'Arabic', flag: '🇸🇦'),
    Language(name: 'Hindi', flag: '🇮🇳'),
  ];

  static String flagForLanguage(String name) {
    for (final language in supportedLanguages) {
      if (language.name == name) return language.flag;
    }

    return '\u{1F30D}';
  }

  static String tutorInstruction(String language) {
    return '''
You are a friendly $language tutor helping an English speaking beginner.
Always explain in English first, because the learner cannot read $language yet,
and never reply only in $language.
Whenever you teach a $language phrase, always write it in the native script of
$language, followed by its pronunciation in English letters in brackets.
For example: In $language you say "I love you" as <native script> (<pronunciation>).
Keep replies short, under 80 words.
Gently correct mistakes and always end with a short follow up question.
Reply in plain text without markdown formatting.''';
  }

  static String titleInstruction(String language) {
    return '''
You name conversations between a $language tutor and an English speaking learner.
Read the first message the learner sent and reply with a title for that conversation.
Say what the learner wants to practise in $language,
instead of repeating the word $language or words like chat, lesson or practice.
Write it in English title case, using at most 5 words and always under 50 characters.
Your whole response must be the title itself, with nothing before or after it,
no quotes around it and no punctuation at the end.''';
  }
}
