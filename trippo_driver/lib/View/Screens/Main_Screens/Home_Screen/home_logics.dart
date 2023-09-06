import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_driver/Container/Repositories/address_parser_repo.dart';
import 'package:trippo_driver/Container/Repositories/firestore_repo.dart';
import 'package:trippo_driver/Container/utils/error_notification.dart';
import 'package:trippo_driver/View/Screens/Main_Screens/Home_Screen/home_providers.dart';
import 'package:trippo_driver/View/Screens/Main_Screens/Home_Screen/home_screen.dart';

class HomeLogics {
  /// [getDriverLoc] fetches a the drivers location as soon as user start the app

  void getDriverLoc(BuildContext context, WidgetRef ref,
      GoogleMapController controller) async {
    try {
      /// get driver's location
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      /// animate camera to current driver's location
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pos.latitude, pos.longitude), zoom: 14)));

      if (context.mounted) {
        /// get human readable address of the driver
        await ref
            .watch(globalAddressParserProvider)
            .humanReadableAddress(pos, context, ref);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void getDriverOnline(BuildContext context, WidgetRef ref,
      GoogleMapController controller) async {
    try {
      /// creating location's Geo Point
      GeoFirePoint myLocation = geo.point(
          latitude:
              ref.read(homeScreenDriversLocationProvider)!.locationLatitude!,
          longitude:
              ref.read(homeScreenDriversLocationProvider)!.locationLongitude!);

      /// set driver's current location
      ref
          .read(globalFirestoreRepoProvider)
          .setDriverLocationStatus(context, myLocation);

      /// track driver's location as driver moves

      Geolocator.getPositionStream().listen((event) {
        ref
            .read(globalFirestoreRepoProvider)
            .setDriverLocationStatus(context, myLocation);
      });

      /// Driver's current position in [LatLng]
      LatLng driverPos = LatLng(
          ref.read(homeScreenDriversLocationProvider)!.locationLatitude!,
          ref.read(homeScreenDriversLocationProvider)!.locationLongitude!);

      /// animate to current driver's position
      controller.animateCamera(CameraUpdate.newLatLng(driverPos));

      ref.read(globalFirestoreRepoProvider).setDriverStatus(context, "Idle");
      ref
          .watch(homeScreenIsDriverActiveProvider.notifier)
          .update((state) => true);
    } catch (e) {
      ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }

  void getDriverOffline(BuildContext context, WidgetRef ref) async {
    try {
      /// deactivate Driver
      ref
          .watch(homeScreenIsDriverActiveProvider.notifier)
          .update((state) => false);

      /// set Driver's status to be offline
      ref.read(globalFirestoreRepoProvider).setDriverStatus(context, "offline");

      /// removve driver's location from database
      ref
          .read(globalFirestoreRepoProvider)
          .setDriverLocationStatus(context, null);

      await Future.delayed(const Duration(seconds: 2));

      /// close the application
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      if (context.mounted) {
        ErrorNotification().showSuccess(context, "You are now Offline");
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  Future<dynamic> sendNotificationToUser(
      BuildContext context, String driverRes) async {
    try {
      await Dio().post("https://fcm.googleapis.com/fcm/send",
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader:
                "Bearer AAAA7vDmw2Y:APA91bH44PYH1e9Idr_iOA76pQmowxa5nFZsEJ3CoxjUeAi4B9L-3GAezzskpynDU-wHYo144fCpbglxLdP6jJZUIHjKA-Q3gDiffy3OK-bWrDw7mQh2FeEwAWxEX1G4Ey_7MEkDanXs"
          }),

          data: {
            "data": {"screen": "home"},
            "notification": {
              "title": "Driver's Response",
              "status" : driverRes,
              "body":
                  " The Driver has $driverRes your request. ${driverRes == "accepted" ? "The Driver will be arriving soon." : "Sorry! The Driver is not available."}"
            },
            "to":
                "eHeH0bV9QbSMvINPFDoo9k:APA91bHrFlYWx5cnoV4cvzwLDrzG_1EYKFAzU0M0CPQyw983SubqiWALhiAVxHntXnaAiUKNPCTfXdK_Ws9LDgc9aJUT_5jvOe9CznTUMxDVFbX4YE7Iu75OMcIj4PTHLiQP0iRgCcm4"
          });
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "$e");
      }
    }
  }
}
