import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laura/models/user_model.dart';

import 'movement_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _movementService = MovementService();

  Future<void> signUp(UserModel user) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password!,
      );

      await userCredential.user!.updateDisplayName(user.name);
    } catch (e) {
      debugPrint('Erro ao registrar: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  User? get currentUser => _auth.currentUser;

  void signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUsername(String newUsername) async =>
      currentUser!.updateDisplayName(newUsername);

  Future<void> updatePassword(String newPassword, String password) async {
    final email = currentUser!.email!;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  Future<void> updateEmail(String newEmail, String password) async {
    final email = currentUser!.email!;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.verifyBeforeUpdateEmail(newEmail);
  }

  Future<bool> hasUserLogged() async {
    return _auth.currentUser != null;
  }

  Future<void> deleteAccount() async {
    final userId = currentUser!.uid;
    var allMovements = await _movementService.getMovements(userId).first;
    allMovements.forEach((element) => _movementService.delete(element.id!));
    await currentUser!.delete();
  }
}
