import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_driver/Container/Repositories/auth_repo.dart';
import 'package:trippo_driver/View/Components/all_components.dart';
import '../../Routes/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
          child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Opacity(
                opacity: 0.2,
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/imgs/main.jpg"))),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Login",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontFamily: "bold", fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                      child: Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Components().returnTextField(
                                emailController, context, false, "Enter Email"),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Components().returnTextField(
                                  passwordController,
                                  context,
                                  true,
                                  "Enter Password"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Consumer(
                                builder: (context, ref, child) {
                                  return InkWell(
                                      onTap: ref.watch(isLoadingProvider)
                                          ? null
                                          : () async {
                                              try {
                                                if (emailController
                                                        .text.isEmpty ||
                                                    passwordController
                                                        .text.isEmpty) {
                                                  ElegantNotification.error(
                                                          height: 50,
                                                          description: const Text(
                                                              "Please Enter Email and Password"))
                                                      .show(context);
                                                  return;
                                                }
                                                ref
                                                    .watch(isLoadingProvider
                                                        .notifier)
                                                    .update((state) => true);

                                                ref
                                                    .watch(authRepoProvider)
                                                    .loginUser(
                                                        emailController.text
                                                            .trim(),
                                                        passwordController.text
                                                            .trim(),
                                                        context);



                                                ref
                                                    .watch(isLoadingProvider
                                                        .notifier)
                                                    .update((state) => false);

                                                if (context.mounted) {
                                                  context.goNamed(
                                                      Routes().navigation);
                                                }
                                              } catch (e) {
                                                ref
                                                    .watch(isLoadingProvider
                                                        .notifier)
                                                    .update((state) => false);
                                                ElegantNotification.error(
                                                        description: Text(
                                                            "An Error Occurred $e"))
                                                    .show(context);
                                              }
                                            },
                                      child: Components().mainButton(
                                          size,
                                          ref.watch(isLoadingProvider)
                                              ? "Loading ..."
                                              : "Login",
                                          context,
                                          ref.watch(isLoadingProvider)
                                              ? Colors.grey
                                              : Colors.blue));
                                },
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  context.goNamed(Routes().register);
                                },
                                child: Text(
                                  "Don't have an account? Sign Up.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          fontFamily: "bold", fontSize: 12),
                                ))
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
