const String geminiModel = 'gemini-3.5-flash-lite';

const String usersCollection = 'users';

const String chatsCollection = 'chats';

const String messagesCollection = 'messages';

const String senderUser = 'user';

const String senderAi = 'ai';

class Language {
  final String name;
  final String flag;

  const Language({required this.name, required this.flag});
}

const List<Language> supportedLanguages = [
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

String flagForLanguage(String name) {
  for (final language in supportedLanguages) {
    if (language.name == name) return language.flag;
  }
  return '🌍';
}

String tutorInstruction(String language) {
  return 'You are a friendly $language tutor helping an English speaking beginner. '
      'Always explain in English first, because the learner cannot read $language yet, '
      'and never reply only in $language. '
      'Whenever you teach a $language phrase, always write it in the native script of '
      '$language, followed by its pronunciation in English letters in brackets. '
      'For example: In $language you say "I love you" as <native script> (<pronunciation>). '
      'Keep replies short, under 80 words. '
      'Gently correct mistakes and always end with a short follow up question. '
      'Reply in plain text without markdown formatting.';
}
