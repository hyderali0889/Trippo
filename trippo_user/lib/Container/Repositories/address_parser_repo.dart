import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_user/Container/utils/keys.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Home_Screen/home_providers.dart';
import '../../Model/direction_model.dart';
import '../utils/error_notification.dart';

/// [addressParserProvider] used to cache the [AddressParser] class to prevent it from creating multiple instances

final globalAddressParserProvider = Provider<AddressParser>((ref) {
  return AddressParser();
});

/// This [AddressParser] has function [humanReadableAddress] which creates address that is in a readable form
/// from the provided [userPosition]'s latitude and longitude and returns response in form of [DIrection] model.

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
        ref.read(homeScreenPickUpLocationProvider.notifier).update((state) => model);

        return res.data["results"][0]["formatted_address"];
      } else {
         ErrorNotification().showError(context, "Failed to get data");
      }
    } catch (e) {
        ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }
}
