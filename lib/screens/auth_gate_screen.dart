import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/state_management/auth_provider.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    if (provider.isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!provider.isSignedIn) return const LoginScreen();

    return const HomeScreen();
  }
}
