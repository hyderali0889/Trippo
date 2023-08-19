import 'dart:async';
import 'package:elegant_notification/elegant_notification.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_driver/Container/Repositories/address_parser_repo.dart';
import 'package:location/location.dart' as loc;
//import 'package:geocoder2/geocoder2.dart';
import 'package:trippo_driver/Container/Repositories/firestore_repo.dart';
//import 'package:trippo_driver/Container/utils/keys.dart';
import '../../../Container/utils/set_blackmap.dart';
import '../../../Model/direction_model.dart';
//import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

// final cameraMovementProvider = StateProvider<LatLng?>((ref) {
//   return null;
// });
final driversLocationProvider = StateProvider<Direction?>((ref) {
  return null;
});
// final dropOffLocationProvider = StateProvider<Direction?>((ref) {
//   return null;
// });

// final addressProvider = StateProvider<String?>((ref) {
//   return null;
// });

final mainPolylinesProvider = StateProvider<Set<Polyline>>((ref) {
  return {};
});

final mainMarkersProvider = StateProvider<Set<Marker>>((ref) {
  return {};
});

final mainCirclesProvider = StateProvider<Set<Circle>>((ref) {
  return {};
});

final isDriverActiveProvider = StateProvider<bool>((ref) {
  return false;
});

final geo = GeoFlutterFire();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  loc.Location location = loc.Location();
  CameraPosition initpos =
      const CameraPosition(target: LatLng(0.0, 0.0), zoom: 14);

  final Completer<GoogleMapController> completer = Completer();
  GoogleMapController? controller;
  Geolocator geoLocator = Geolocator();

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

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
                      getDriverLoc();
                      ref
                          .watch(firestoreRepoProvider)
                          .getDriverDetails(context);
                    },
                   
                  ),
                  ref.watch(isDriverActiveProvider)
                      ? Container()
                      : Container(
                          height: size.height,
                          width: size.width,
                          color: Colors.black54),
                  Positioned(
                      top: !ref.watch(isDriverActiveProvider)
                          ? size.height * 0.45
                          : 45,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (!ref.watch(isDriverActiveProvider)) {
                                getDriverOnline();
                              } else {
                                getDriverOffline();
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 45,
                              width: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.blue),
                              child: !ref.watch(isDriverActiveProvider)
                                  ? const Text("You are Offline")
                                  : const Icon(Icons.phonelink_ring_outlined,
                                      color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ))
                ],
              ))),
    );
  }

  // end of body

  /// [checkPermissions] checking the permission status

  void checkPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
        return;
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        return;
      }
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }

  /// [getDriverLoc] fetches a the drivers location as soon as user start the app

  void getDriverLoc() async {
    try {

      /// get driver's location
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
/// animate camera to current driver's location
      controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pos.latitude, pos.longitude), zoom: 14)));

      if (context.mounted) {
        /// get human readable address of the driver
        await ref
            .watch(addressParserProvider)
            .humanReadableAddress(pos, context, ref);
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
  /// from the [cameraMovementProvider] and returns a [Direction] model which is assigned to [driversLocationProvider] (which sets the user's pick up Location)

  // void getAddressfromCordinates() async {
  //   try {
  //     if (ref.read(cameraMovementProvider) == null) {
  //       return;
  //     }

  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: ref.read(cameraMovementProvider)!.latitude,
  //         longitude: ref.read(cameraMovementProvider)!.longitude,
  //         googleMapApiKey: mapKey);

  //     Direction model = Direction(
  //         locationLatitude: data.latitude,
  //         locationLongitude: data.longitude,
  //         humanReadableAddress: data.address);

  //     ref.read(driversLocationProvider.notifier).update((state) => model);
  //   } catch (e) {
  //     ElegantNotification.error(
  //         description: Text(
  //       "An Error Occurred $e",
  //       style: const TextStyle(color: Colors.black),
  //     )).show(context);
  //   }
  // }

  void getDriverOnline() async {
    try {
      /// creating location's Geo Point
      GeoFirePoint myLocation = geo.point(
          latitude: ref.read(driversLocationProvider)!.locationLatitude!,
          longitude: ref.read(driversLocationProvider)!.locationLongitude!);

  /// set driver's current location
      ref
          .read(firestoreRepoProvider)
          .setDriverLocationStatus(context, myLocation);

 /// track driver's location as driver moves

 Geolocator.getPositionStream().listen((event) {
         ref
          .read(firestoreRepoProvider)
          .setDriverLocationStatus(context, myLocation);

      });

/// Driver's current position in [LatLng]
      LatLng driverPos = LatLng(
          ref.read(driversLocationProvider)!.locationLatitude!,
          ref.read(driversLocationProvider)!.locationLongitude!);


 /// animate to current driver's position
      controller!.animateCamera(CameraUpdate.newLatLng(driverPos));

      ref.read(firestoreRepoProvider).setDriverStatus(context, "Idle");
      ref.watch(isDriverActiveProvider.notifier).update((state) => true);
    } catch (e) {
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }

  void getDriverOffline() async {
    try {

    /// deactivate Driver
      ref.watch(isDriverActiveProvider.notifier).update((state) => false);
  /// set Driver's status to be offline
      ref.read(firestoreRepoProvider).setDriverStatus(context, "offline");
  /// removve driver's location from database
      ref.read(firestoreRepoProvider).setDriverLocationStatus(context, null);

      await Future.delayed(const Duration(seconds: 2));
  /// close the application
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      if (context.mounted) {
        ElegantNotification.success(
            description: const Text(
          "You are now Offline",
          style: TextStyle(color: Colors.black),
        )).show(context);
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
