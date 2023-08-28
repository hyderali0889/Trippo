import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../View/Routes/routes.dart';
import '../utils/error_notification.dart';

/// [authRepoProvider] used to cache the [AuthRepo] class to prevent it from creating multiple instances

final globalAuthRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo();
});

/// [AuthRepo] provides functions used for authentication purposes

class AuthRepo {
  void loginUser(email, password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        context.goNamed(Routes().home);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void registerUser(email, password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        context.goNamed(Routes().home);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
