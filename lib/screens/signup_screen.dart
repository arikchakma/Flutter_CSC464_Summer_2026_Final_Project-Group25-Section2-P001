import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/state_management/auth_provider.dart';
import 'package:final_project/utility/validators.dart';
import 'package:final_project/widgets/auth_error_widget.dart';
import 'package:final_project/widgets/auth_field_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final name = _name.text.trim();

    final created = await context.read<AuthProvider>().signUp(
      name: name,
      email: _email.text,
      password: _password.text,
    );

    if (!created || !mounted) return;

    _formKey.currentState!.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created. Welcome, $name!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                    Text(
                      'Start learning',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your conversations are saved to your account.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    AuthFieldWidget(
                      controller: _name,
                      label: 'Name',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      validator: CustomValidators.validateName,
                    ),
                    const SizedBox(height: 16),
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
                      validator: CustomValidators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    AuthFieldWidget(
                      controller: _confirmPassword,
                      label: 'Confirm password',
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) =>
                          CustomValidators.validateConfirmPassword(
                            value,
                            _password.text,
                          ),
                      onSubmitted: _signUp,
                    ),
                    if (provider.error != null) ...[
                      const SizedBox(height: 16),
                      AuthErrorWidget(message: provider.error!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: provider.isSubmitting ? null : _signUp,
                      child: provider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
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
