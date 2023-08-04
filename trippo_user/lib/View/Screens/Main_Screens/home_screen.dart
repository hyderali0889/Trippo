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
import 'package:trippo_user/Container/utils/keys.dart';
import '../../../Container/Repositories/direction_polylines_repo.dart';
import '../../../Container/utils/set_blackmap.dart';
import '../../../Model/direction_model.dart';
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
                  const Align(
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
                      height: 250,
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
                                          maxLines: 3,
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
                                onTap: () async {
                                  context.pushNamed(Routes().whereTo,
                                      extra: controller).then((value){
                                            ref
              .watch(directionPolylinesRepoProvider)
              .setNewDirectionPolylines(ref, context, controller);
                                      });
                                },
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
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  )
                ],
              ))),
    );
  }

  // end of body

  void checkPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        return;
      }
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred 3 $e"))
          .show(context);
    }
  }

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
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred 1 $e"))
          .show(context);
    }
  }

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
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }
}