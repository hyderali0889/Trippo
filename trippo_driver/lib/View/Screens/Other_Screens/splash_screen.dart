import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    initializeUser();
  }



  void initializeUser() async {

    final User? user = _auth.currentUser;

    if (user != null) {
      Timer(
        const Duration(seconds: 3),
        () {
          context.goNamed(Routes().navigationScreen);
        },
      );
    } else {
      Timer(const Duration(seconds: 3), () {
        context.goNamed(Routes().login);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
          child: SizedBox(
              width: size.width,
              height: size.height,
              child: Center(
                child: Text(
                  "Trippo",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontFamily: "bold", fontSize: 54),
                ),
              ))),
    );
  }
}
