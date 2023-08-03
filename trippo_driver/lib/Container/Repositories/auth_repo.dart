import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../View/Routes/routes.dart';
import 'firestore_repo.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo();
});

class AuthRepo {
  FirebaseAuth auth = FirebaseAuth.instance;

  void loginUser(email, password, context) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }

  void registerUser(name, email, password, context, WidgetRef ref) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (FirebaseAuth.instance.currentUser == null) {
        return;
      }

      ref.watch(firestoreRepoProvider).addNameToFirestore(name, email, context);

      
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }

  void logOut(BuildContext context) async {
    try {
      await auth.signOut();

      if (context.mounted) {
        context.goNamed(Routes().login);
      }
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }
}
