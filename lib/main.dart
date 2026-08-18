import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/firebase_options.dart';
import 'package:final_project/screens/auth_gate.dart';
import 'package:final_project/state_management/auth_provider.dart';
import 'package:final_project/state_management/chat_provider.dart';
import 'package:final_project/state_management/message_provider.dart';
import 'package:final_project/utility/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (context) => ChatProvider(),
          update: (context, auth, chats) =>
              (chats ?? ChatProvider())..setUser(auth.account?.uid),
        ),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'AI Language Tutor',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AuthGate(),
      ),
    );
  }
}
