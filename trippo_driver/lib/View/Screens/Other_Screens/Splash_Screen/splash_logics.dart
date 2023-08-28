import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_driver/Container/utils/error_notification.dart';
import 'package:trippo_driver/View/Routes/routes.dart';

class SplashLogics{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initializeUser(BuildContext context) async {
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

  /// [checkPermissions] checking the permission status

  void checkPermissions(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
        LocationPermission permission2 = await Geolocator.checkPermission();
        if (context.mounted &&
            (permission2 == LocationPermission.whileInUse ||
                permission2 == LocationPermission.always)) {
          initializeUser(context);
        }else{
             if(context.mounted){
        ErrorNotification().showError(context, "Location Access is required to run Trippo.");

      }

           await Future.delayed(const Duration(seconds:2 ));
             SystemChannels.platform.invokeMethod("SystemNavigator.exitApplication");
        }
        return;
      }else if (context.mounted &&
           ( permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always)) {
          initializeUser(context);
          return;
        }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        if (context.mounted) {
          ErrorNotification().showError(context,  "Location Access is required to run Trippo.");
      await Future.delayed(const Duration(seconds:2 ));
             SystemChannels.platform.invokeMethod("SystemNavigator.exitApplication");
        }
        return;
      }
    } catch (e) {
      if(context.mounted){
       ErrorNotification().showError(context, "An Error Occurred $e");

      }

    }
  }
}