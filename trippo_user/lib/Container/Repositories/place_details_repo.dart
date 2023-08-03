import 'package:dio/dio.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_user/Container/utils/keys.dart';
import 'package:trippo_user/View/Screens/Main_Screens/home_screen.dart';
import '../../Model/direction_model.dart';
import '../../View/Screens/Main_Screens/Sub_Screens/where_to_screen.dart';

final placeDetailsRepoProvider = Provider<PlaceDetailsRepo>((ref) {
  return PlaceDetailsRepo();
});

class PlaceDetailsRepo {
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
