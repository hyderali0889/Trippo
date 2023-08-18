import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../View/Routes/routes.dart';

/// [authRepoProvider] used to cache the [AuthRepo] class to prevent it from creating multiple instances

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo();
});

/// [AuthRepo] provides functions used for authentication purposes

class AuthRepo {
  void loginUser(email, password,BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
           if (context.mounted) {
                                                  context.goNamed(
                                                      Routes().home);
                                                }
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }

  void registerUser(email, password,BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
           if (context.mounted) {
                                                  context.goNamed(
                                                      Routes().home);
                                                }
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }
}
