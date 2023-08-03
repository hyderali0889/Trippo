import 'package:dio/dio.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_user/Container/utils/keys.dart';
import 'package:trippo_user/View/Screens/Main_Screens/home_screen.dart';
import '../../Model/direction_model.dart';

final addressParserProvider = Provider<AddressParser>((ref) {
  return AddressParser();
});

class AddressParser {
  dynamic humanReadableAddress(
      Position userPosition, context, WidgetRef ref) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${userPosition.latitude},${userPosition.longitude}&key=$mapKey";

      Response res = await Dio().get(url);

      if (res.statusCode == 200) {
        Direction model = Direction(
            locationLatitude: userPosition.latitude,
            locationLongitude: userPosition.longitude,
            humanReadableAddress: res.data["results"][0]["formatted_address"]);
        ref.read(pickUpLocationProvider.notifier).update((state) => model);

        return res.data["results"][0]["formatted_address"];
      } else {
        ElegantNotification.error(description: const Text("Failed to get data"))
            .show(context);
      }
    } catch (e) {
      print("error data is $e");
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }
}
