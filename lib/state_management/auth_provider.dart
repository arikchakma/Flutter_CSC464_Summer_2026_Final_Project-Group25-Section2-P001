import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';

import 'package:final_project/models/user_model.dart';
import 'package:final_project/utility/constant.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference _users = FirebaseFirestore.instance.collection(
    usersCollection,
  );

  StreamSubscription<User?>? _subscription;

  User? account;
  UserModel? profile;
  bool isChecking = true;
  bool isSubmitting = false;
  String? error;

  bool get isSignedIn => account != null;

  String get displayName => profile?.name ?? account?.displayName ?? 'there';

  AuthProvider() {
    _subscription = _auth.authStateChanges().listen((user) {
      account = user;
      profile = null;
      isChecking = false;
      notifyListeners();

      if (user != null) _loadProfile(user.uid);
    });
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || account?.uid != uid) return;

      profile = UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return _submit(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      final newProfile = UserModel(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      await _users.doc(user.uid).set(newProfile.toJson());
      await user.updateDisplayName(newProfile.name);

      profile = newProfile;
    });
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _submit(() async {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<void> signOut() async {
    error = null;
    await _auth.signOut();
  }

  void clearError() {
    if (error == null) return;

    error = null;
    notifyListeners();
  }

  Future<bool> _submit(Future<void> Function() action) async {
    if (isSubmitting) return false;

    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on FirebaseAuthException catch (exception) {
      error = _messageFor(exception.code);
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'That email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'That email address does not look right.';
      case 'weak-password':
        return 'Please choose a stronger password of at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'operation-not-allowed':
        return 'Email sign in is turned off for this project.';
      default:
        return 'Could not complete that. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
