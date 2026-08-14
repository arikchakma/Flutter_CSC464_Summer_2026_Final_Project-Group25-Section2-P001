class CustomValidators {
  static String? validateName(String? value) {
    final name = (value ?? '').trim();

    if (name.isEmpty) return 'Please enter your name.';
    if (name.length < 2) return 'Your name is a little too short.';

    return null;
  }

  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) return 'Please enter your email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'That email address does not look right.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return 'Please enter a password.';
    if (password.length < 6) return 'Use at least 6 characters.';

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Please confirm your password.';
    if (value != password) return 'Both passwords must match.';

    return null;
  }
}
