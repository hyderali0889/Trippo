import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_driver/Container/Repositories/auth_repo.dart';
import 'package:trippo_driver/Container/utils/error_notification.dart';
import 'package:trippo_driver/View/Screens/Auth_Screens/Login_Screen/login_providers.dart';

class LoginLogics {
  void loginUser(
      BuildContext context,
      WidgetRef ref,
      TextEditingController emailController,
      TextEditingController passwordController) {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ErrorNotification()
            .showError(context, "Please Enter Email and Password");

        return;
      }
      ref.watch(loginIsLoadingProvider.notifier).update((state) => true);

      ref.watch(globalAuthRepoProvider).loginUser(
          emailController.text.trim(), passwordController.text.trim(), context);

      ref.watch(loginIsLoadingProvider.notifier).update((state) => false);


    } catch (e) {
      ref.watch(loginIsLoadingProvider.notifier).update((state) => false);

      ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }
}
