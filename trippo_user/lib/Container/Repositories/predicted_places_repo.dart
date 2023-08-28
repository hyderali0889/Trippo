import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_user/Container/utils/keys.dart';
import 'package:trippo_user/Model/predicted_places.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Sub_Screens/Where_To_Screen/where_to_providers.dart';
import '../utils/error_notification.dart';

/// [predictedPlacesRepoProvider] used to cache the [PredictedPlacesRepo] class to prevent it from creating multiple instances

final globalPredictedPlacesRepoProvider = Provider<PredictedPlacesRepo>((ref) {
  return PredictedPlacesRepo();
});

class PredictedPlacesRepo {
  /// [getAllPredictedPlaces] gets the details of the location by getting the string from [text] and fetching the
  /// data related to this [text] and showing them inside the [WhereTo] screen as user adds types more words new [autoComplete] items are added to the
  /// [ListView] in the [WhereTo] screen by adding the newly created list of [predictedPlacesList] to the provider [predictedPlacesProvider] located in the [WhereTo] Screen

  void getAllPredictedPlaces(
      String text, BuildContext context, WidgetRef ref) async {
    try {
      if (text.length < 2) {
        return;
      }
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=$mapKey&components=country:pk";

      Response res = await Dio().get(url);

      if (res.statusCode == 200) {
        var placePrediction = res.data["predictions"];

        var predictedPlacesList = (placePrediction as List)
            .map((e) => PredictedPlaces.fromJson(e))
            .toList();

        ref
            .read(whereToPredictedPlacesProvider.notifier)
            .update((state) => predictedPlacesList);
      } else {
        if (context.mounted) {
          ErrorNotification().showError(context, "Failed to get data");
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
