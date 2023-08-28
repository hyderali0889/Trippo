import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_user/View/Screens/Auth_Screens/Register_Screen/register_logics.dart';
import 'package:trippo_user/View/Screens/Auth_Screens/Register_Screen/register_providers.dart';
import '../../../Components/all_components.dart';
import '../../../Routes/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
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
                      "Register",
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
                                nameController, context, false, "Enter Name"),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Components().returnTextField(
                                  emailController,
                                  context,
                                  false,
                                  "Enter Email"),
                            ),
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
                                      onTap:
                                          ref.watch(registerIsLoadingProvider)
                                              ? null
                                              : () =>RegisterLogics().registerUser(context ,ref , nameController , emailController , passwordController),
                                      child: Components().mainButton(
                                          size,
                                          ref.watch(registerIsLoadingProvider)
                                              ? "Loading ..."
                                              : "Register",
                                          context,
                                          ref.watch(registerIsLoadingProvider)
                                              ? Colors.grey
                                              : Colors.blue));
                                },
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  context.goNamed(Routes().login);
                                },
                                child: Text(
                                  "Login.",
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
