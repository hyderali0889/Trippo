import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../Container/utils/error_notification.dart';
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
   checkPermissions();
  }



  void initializeUser() async {

    final User? user = _auth.currentUser;

    if (user != null) {
      Timer(
        const Duration(seconds: 3),
        () {
          context.goNamed(Routes().home);
        },
      );
    } else {
      Timer(const Duration(seconds: 3), () {
        context.goNamed(Routes().login);
      });
    }
  }


  /// [checkPermissions] checking the permission status

  void checkPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
        LocationPermission permission2 = await Geolocator.checkPermission();
        if (context.mounted &&
            (permission2 == LocationPermission.whileInUse ||
                permission2 == LocationPermission.always)) {
          initializeUser();
        }
        return;
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        if (context.mounted) {
          ErrorNotification().showError(context, "Cannot get you location");

        }
        return;
      }
    } catch (e) {
       ErrorNotification().showError(context, "An Error Occurred $e");

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
