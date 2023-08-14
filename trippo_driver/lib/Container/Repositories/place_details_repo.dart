import 'package:dio/dio.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_driver/Container/utils/keys.dart';
import 'package:trippo_driver/View/Screens/Main_Screens/home_screen.dart';
import '../../Model/direction_model.dart';
import '../../View/Screens/Main_Screens/Sub_Screens/where_to_screen.dart';
/// [placeDetailsRepoProvider] used to cache the [PlaceDetailsRepo] class to prevent it from creating multiple instances

final placeDetailsRepoProvider = Provider<PlaceDetailsRepo>((ref) {
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
            .read(dropOffLocationProvider.notifier)
            .update((state) => placeDetails);

        ref.read(whereToLoadingProvider.notifier).update((state) => false);


          if (context.mounted) {
            context.pop();
          }

      } else {
        if (context.mounted) {
          ElegantNotification.error(
                  description: const Text("Failed to get data"))
              .show(context);
        }
      }
    } catch (e) {
      print("error data is $e");
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }
}
