import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_user/Container/utils/keys.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Home_Screen/home_providers.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Sub_Screens/Where_To_Screen/where_to_providers.dart';
import '../../Model/direction_model.dart';
import '../utils/error_notification.dart';

/// [placeDetailsRepoProvider] used to cache the [PlaceDetailsRepo] class to prevent it from creating multiple instances

final globalPlaceDetailsRepoProvider = Provider<PlaceDetailsRepo>((ref) {
  return PlaceDetailsRepo();
});

class PlaceDetailsRepo {
  /// [getAllPredictedPlaceDetails] gets the details of the location by getting location ID from [placeId] and fetching the
  /// data related to this [placeId] when user Clicks on any item inside of the [ListView] in the [WhereTo] screen and return a [Direction] model which directing user back to [HomeScreen]

  Future<dynamic> getAllPredictedPlaceDetails(
      String placeId, BuildContext context, WidgetRef ref, controller) async {
    try {
      ref.read(whereToLoadingProvider.notifier).update((state) => true);

      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

      Response res = await Dio().get(url);

      if (res.statusCode == 200) {
        Direction placeDetails = Direction(
          locationName: res.data["result"]["name"],
          locationId: placeId,
          locationLatitude: res.data["result"]["geometry"]["location"]["lat"],
          locationLongitude: res.data["result"]["geometry"]["location"]["lng"],
        );

        ref
            .read(homeScreenDropOffLocationProvider.notifier)
            .update((state) => placeDetails);

        ref.read(whereToLoadingProvider.notifier).update((state) => false);
      } else {
        if (context.mounted) {
          ErrorNotification().showError(context, "Failed to get data");
        }
      }
    } catch (e) {
      print("err is $e");
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
