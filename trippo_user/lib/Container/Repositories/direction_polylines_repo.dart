import 'package:dio/dio.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Container/utils/keys.dart';
import 'package:trippo_user/Model/direction_polyline_details_model.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Home_Screen/home_providers.dart';

import '../utils/error_notification.dart';

/// [directionPolylinesRepoProvider] used to cache the [DirectionPolylines] class to prevent it from creating multiple instances

final globalDirectionPolylinesRepoProvider =
    Provider<DirectionPolylines>((ref) {
  return DirectionPolylines();
});

class DirectionPolylines {
  List<LatLng> pLinesCoordinatedList = [];

  /// [setNewDirectionPolylines] function takes the [DirectionPolylineDetails] model from the [getDirectionsPolylines] function
  ///  and adds the decoded polylines data to [pLinesCoordinatedList] and creates a new [polyline] variable and alots the var to [mainPolylinesProvider] located in the [HomeScreen]
  /// and creates LatLng [Bounds] which would animates the [GoogleMapsController] controller to the new position with polylines on [map] and with 65 [padding]

  void setNewDirectionPolylines(ref, context, controller) async {
    try {
      DirectionPolylineDetails model =
          await getDirectionsPolylines(context, ref);
      await calculateRideRate(context, ref);

      PolylinePoints points = PolylinePoints();
      List<PointLatLng> decodedPolylines =
          points.decodePolyline(model.epoints!);

      pLinesCoordinatedList.clear();

      if (decodedPolylines.isNotEmpty) {
        for (PointLatLng polyline in decodedPolylines) {
          pLinesCoordinatedList
              .add(LatLng(polyline.latitude, polyline.longitude));
        }
      }

      ref.read(homeScreenMainPolylinesProvider).clear();

      Polyline newPolyline = Polyline(
          color: Colors.blue,
          polylineId: const PolylineId("polylineId"),
          jointType: JointType.round,
          points: pLinesCoordinatedList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          width: 5);

      ref
          .read(homeScreenMainPolylinesProvider.notifier)
          .update((Set<Polyline> state) => {...state, newPolyline});

      double miny = (ref
                  .read(homeScreenPickUpLocationProvider)!
                  .locationLatitude! <=
              ref.read(homeScreenDropOffLocationProvider)!.locationLatitude!)
          ? ref.read(homeScreenPickUpLocationProvider)!.locationLatitude!
          : ref.read(homeScreenDropOffLocationProvider)!.locationLatitude!;

      double minx = (ref
                  .read(homeScreenPickUpLocationProvider)!
                  .locationLongitude <=
              ref.read(homeScreenDropOffLocationProvider)!.locationLongitude!)
          ? ref.read(homeScreenPickUpLocationProvider)!.locationLongitude
          : ref.read(homeScreenDropOffLocationProvider)!.locationLongitude!;
      double maxy = (ref
                  .read(homeScreenPickUpLocationProvider)!
                  .locationLatitude! <=
              ref.read(homeScreenDropOffLocationProvider)!.locationLatitude!)
          ? ref.read(homeScreenDropOffLocationProvider)!.locationLatitude!
          : ref.read(homeScreenPickUpLocationProvider)!.locationLatitude!;
      double maxx = (ref
                  .read(homeScreenPickUpLocationProvider)!
                  .locationLongitude <=
              ref.read(homeScreenDropOffLocationProvider)!.locationLongitude!)
          ? ref.read(homeScreenDropOffLocationProvider)!.locationLongitude!
          : ref.read(homeScreenPickUpLocationProvider)!.locationLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(southWestLatitude, southWestLongitude),
          northeast: LatLng(northEastLatitude, northEastLongitude));

      controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }

  /// [getDirectionsPolylines] function takes the [pickUpDestination] and  the [dropOffDestination] from the user and fetches the direction data from google maps api
  /// and returns the response in form of [DirectionPolylineDetails]

  Future<dynamic> getDirectionsPolylines(context, WidgetRef ref) async {
    try {
      LatLng pickUpDestination = LatLng(
          ref.read(homeScreenPickUpLocationProvider)!.locationLatitude!,
          ref.read(homeScreenPickUpLocationProvider)!.locationLongitude!);
      LatLng dropOffDestination = LatLng(
          ref.read(homeScreenDropOffLocationProvider)!.locationLatitude!,
          ref.read(homeScreenDropOffLocationProvider)!.locationLongitude!);

      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${pickUpDestination.latitude},${pickUpDestination.longitude}&destination=${dropOffDestination.latitude},${dropOffDestination.longitude}&key=$mapKey";

      Response res = await Dio().get(url);

      if (res.statusCode == 200) {
        DirectionPolylineDetails model = DirectionPolylineDetails(
          epoints: res.data["routes"][0]["overview_polyline"]["points"],
          distanceText: res.data["routes"][0]["legs"][0]["distance"]["text"],
          distanceValue: res.data["routes"][0]["legs"][0]["distance"]["value"],
          durationText: res.data["routes"][0]["legs"][0]["duration"]["text"],
          durationValue: res.data["routes"][0]["legs"][0]["duration"]["value"],
        );

        return model;
      } else {
        ErrorNotification().showError(context, "Failed to get data");
      }
    } catch (e) {
      ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }

  /// [calculateRideRate] calculates the fare of the user's travel

  Future<dynamic> calculateRideRate(context, WidgetRef ref) async {
    try {
      DirectionPolylineDetails model =
          await getDirectionsPolylines(context, ref);
      double travelFarePerMin = (model.distanceValue! / 60) * 0.1;
      double distanceFarePerKM = (model.distanceValue! / 1000) * 0.1;

      double totalFare = travelFarePerMin + distanceFarePerKM;

      ref
          .read(homeScreenRateProvider.notifier)
          .update((state) => double.parse(totalFare.toStringAsFixed(2)));
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
      return 0;
    }
  }
}
