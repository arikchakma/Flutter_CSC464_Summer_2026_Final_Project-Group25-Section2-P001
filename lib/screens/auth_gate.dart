import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/state_management/auth_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    if (provider.isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!provider.isSignedIn) return const LoginScreen();

    return const SignedInScreen();
  }
}

class SignedInScreen extends StatelessWidget {
  const SignedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Language Tutor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: provider.signOut,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Signed in as ${provider.displayName}.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
