import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/screens/signup_screen.dart';
import 'package:final_project/state_management/auth_provider.dart';
import 'package:final_project/utility/validators.dart';
import 'package:final_project/widgets/auth_error_widget.dart';
import 'package:final_project/widgets/auth_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    await context.read<AuthProvider>().signIn(
      email: _email.text,
      password: _password.text,
    );
  }

  void _openSignUp() {
    context.read<AuthProvider>().clearError();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '🌍',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 56),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to continue practising with your tutor.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    AuthFieldWidget(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: CustomValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    AuthFieldWidget(
                      controller: _password,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: CustomValidators.validatePassword,
                      onSubmitted: _signIn,
                    ),
                    if (provider.error != null) ...[
                      const SizedBox(height: 16),
                      AuthErrorWidget(message: provider.error!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: provider.isSubmitting ? null : _signIn,
                      child: provider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: provider.isSubmitting ? null : _openSignUp,
                      child: const Text("New here? Create an account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
