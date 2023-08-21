import 'dart:async';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Container/Repositories/address_parser_repo.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoder2/geocoder2.dart';
import 'package:trippo_user/Container/Repositories/firestore_repo.dart';
import 'package:trippo_user/Container/utils/keys.dart';
import '../../../Container/Repositories/direction_polylines_repo.dart';
import '../../../Container/utils/set_blackmap.dart';
import '../../../Model/direction_model.dart';
import '../../../Model/driver_model.dart';
import '../../Routes/routes.dart';

final cameraMovementProvider = StateProvider<LatLng?>((ref) {
  return null;
});
final pickUpLocationProvider = StateProvider<Direction?>((ref) {
  return null;
});
final dropOffLocationProvider = StateProvider<Direction?>((ref) {
  return null;
});

final availableDriversProvider = StateProvider<List<DriverModel>>((ref) {
  return [];
});

final addressProvider = StateProvider<String?>((ref) {
  return null;
});

final mainPolylinesProvider = StateProvider<Set<Polyline>>((ref) {
  return {};
});

final mainMarkersProvider = StateProvider<Set<Marker>>((ref) {
  return {};
});

final mainCirclesProvider = StateProvider<Set<Circle>>((ref) {
  return {};
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController whereToController = TextEditingController();
  loc.Location location = loc.Location();
  CameraPosition initpos =
      const CameraPosition(target: LatLng(0.0, 0.0), zoom: 14);

  final Completer<GoogleMapController> completer = Completer();
  GoogleMapController? controller;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
          child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    trafficEnabled: true,
                    compassEnabled: true,
                    buildingsEnabled: true,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: initpos,
                    polylines: ref.watch(mainPolylinesProvider),
                    markers: ref.watch(mainMarkersProvider),
                    circles: ref.watch(mainCirclesProvider),
                    onMapCreated: (map) {
                      completer.complete(map);
                      controller = map;
                      SetBlackMap().setBlackMapTheme(map);
                      getUserLoc();
                    },
                    onCameraMove: (CameraPosition pos) {
                      if (ref.watch(cameraMovementProvider) != pos.target) {
                        ref
                            .watch(cameraMovementProvider.notifier)
                            .update((state) => pos.target);
                      }
                    },
                    onCameraIdle: () {
                      getAddressfromCordinates();
                    },
                  ),
                  ref.watch(dropOffLocationProvider) != null
                      ? Container()
                      : const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.location_on,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 320,
                      width: size.width,
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  "From",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Container(
                                  width: size.width * 0.9,
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom:
                                              BorderSide(color: Colors.blue))),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.start_outlined,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.7,
                                        child: Text(
                                          ref
                                                  .watch(pickUpLocationProvider)
                                                  ?.humanReadableAddress ??
                                              "Loading ...",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  "To",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              InkWell(
                                onTap: () => openWhereToScreen(),
                                child: Container(
                                  width: size.width * 0.9,
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom:
                                              BorderSide(color: Colors.blue))),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.pin_drop_outlined,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.7,
                                        child: Text(
                                          ref
                                                  .watch(
                                                      dropOffLocationProvider)
                                                  ?.locationName ??
                                              "Where To",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: changePickUpLoc,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 50,
                                        width: size.width * 0.4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                            color: Colors.blue),
                                        child: Text(
                                          "Change Pickup Location",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 50,
                                        width: size.width * 0.4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                            color: Colors.orange),
                                        child: Text(
                                          "Request a Ride",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ]),
                      ),
                    ),
                  )
                ],
              ))),
    );
  }

  // end of body



  void changePickUpLoc() async {
    try {
      ref.watch(dropOffLocationProvider.notifier).update((state) => null);

      ref
          .watch(mainMarkersProvider)
          .removeWhere((element) => element.markerId.value == "pickUpId");
      ref
          .watch(mainMarkersProvider)
          .removeWhere((element) => element.markerId.value == "dropOffId");
      ref
          .watch(mainCirclesProvider)
          .removeWhere((ele) => ele.circleId.value == "pickUpCircle");
      ref
          .watch(mainCirclesProvider)
          .removeWhere((ele) => ele.circleId.value == "dropOffCircle");
      ref.watch(mainPolylinesProvider.notifier).update((state) => {});
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pos.latitude, pos.longitude), zoom: 14)));
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }

  /// [getUserLoc] fetches a the users location as soon as user start the app

  void getUserLoc() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pos.latitude, pos.longitude), zoom: 14)));

      if (context.mounted) {
        await ref
            .watch(addressParserProvider)
            .humanReadableAddress(pos, context, ref);
      }
      if (context.mounted) {
        ref.read(firestoreRepoProvider).getDriverData(context, ref,LatLng(pos.latitude, pos.longitude));
      }
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }

  /// [getAddressfromCordinates] read data from [cameraMovementProvider] (which is updated whenever the camera moves) and gets the human readable address
  /// from the [cameraMovementProvider] and returns a [Direction] model which is assigned to [pickUpLocationProvider] (which sets the user's pick up Location)

  void getAddressfromCordinates() async {
    try {
      if (ref.read(cameraMovementProvider) == null) {
        return;
      }

      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: ref.read(cameraMovementProvider)!.latitude,
          longitude: ref.read(cameraMovementProvider)!.longitude,
          googleMapApiKey: mapKey);

      Direction model = Direction(
          locationLatitude: data.latitude,
          locationLongitude: data.longitude,
          humanReadableAddress: data.address);

      ref.read(pickUpLocationProvider.notifier).update((state) => model);
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }

  /// Function for [WhereTo] TextField Button

  void openWhereToScreen() async {
    try {
      await context.pushNamed(Routes().whereTo, extra: controller);

      if (ref.watch(dropOffLocationProvider) == null) {
        return;
      }

      if (context.mounted) {
        /// Making [Markers] for [pickUp] and [dropOff] Places
        Marker pickUpMarker = Marker(
            markerId: const MarkerId("pickUpId"),
            infoWindow: InfoWindow(
              title: ref.watch(pickUpLocationProvider)!.locationName,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: LatLng(
                ref.watch(pickUpLocationProvider)!.locationLatitude!,
                ref.watch(pickUpLocationProvider)!.locationLongitude!));
        Marker dropOffMarker = Marker(
            markerId: const MarkerId("dropOffId"),
            infoWindow: InfoWindow(
              title: ref.watch(dropOffLocationProvider)!.locationName,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: LatLng(
                ref.watch(dropOffLocationProvider)!.locationLatitude!,
                ref.watch(dropOffLocationProvider)!.locationLongitude!));

        /// Making [Circle] for [pickUp] and [dropOff] Places

        Circle pickUpCircle = Circle(
            circleId: const CircleId("pickUpCircle"),
            fillColor: Colors.green,
            radius: 500,
            strokeColor: Colors.black,
            center: LatLng(ref.watch(pickUpLocationProvider)!.locationLatitude!,
                ref.watch(pickUpLocationProvider)!.locationLongitude!));
        Circle dropOffCircle = Circle(
            circleId: const CircleId("dropOffCircle"),
            fillColor: Colors.red,
            radius: 500,
            strokeColor: Colors.black,
            center: LatLng(
                ref.watch(dropOffLocationProvider)!.locationLatitude!,
                ref.watch(dropOffLocationProvider)!.locationLongitude!));

        /// Calling function to draw [Polylines]
        ref
            .watch(directionPolylinesRepoProvider)
            .setNewDirectionPolylines(ref, context, controller);

        /// Adding [Markers] to [pickUp] and [dropOff] Places
        ref
            .watch(mainMarkersProvider.notifier)
            .update((state) => {...state, pickUpMarker, dropOffMarker});

        /// Adding [Circles] to [pickUp] and [dropOff] Places
        ref
            .watch(mainCirclesProvider.notifier)
            .update((state) => {...state, pickUpCircle, dropOffCircle});
      }
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }
}
