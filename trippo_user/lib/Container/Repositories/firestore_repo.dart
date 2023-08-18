import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Model/driver_model.dart';
import 'package:trippo_user/View/Screens/Main_Screens/home_screen.dart';

final firestoreRepoProvider = Provider<FirestoreRepo>((ref) {
  return FirestoreRepo();
});

class FirestoreRepo {
  final geo = GeoFlutterFire();
  FirebaseFirestore db = FirebaseFirestore.instance;
  void getDriverData(BuildContext context, WidgetRef ref) async {
    try {
      QuerySnapshot<Map<String, dynamic>> drivers =
          await db.collection("Drivers").get();

      for (var driver in drivers.docs) {
        DriverModel model = DriverModel(
            driver.data()["Car Name"],
            driver.data()["Car Plate Num"],
            driver.data()["Car Type"],
            geo.point(
                latitude: driver.data()["driverLoc"]["geopoint"].latitude,
                longitude: driver.data()["driverLoc"]["geopoint"].longitude),
            driver.data()["driverStatus"],
            driver.data()["email"],
            driver.data()["name"]);

        if (driver.data()["driverStatus"] == "offline") {
          return;
        }

        Marker marker = Marker(
            markerId:  MarkerId(driver.data()["Car Name"]),
            infoWindow: InfoWindow(title: driver.data()["Car Name"] ,),
            position: LatLng(driver.data()["driverLoc"]["geopoint"].latitude,
                driver.data()["driverLoc"]["geopoint"].longitude),
            icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(),
              "assets/imgs/sedan.png",
            ));

        ref
            .read(mainMarkersProvider.notifier)
            .update((state) => {...state, marker});

        ref
            .read(availableDriversProvider.notifier)
            .update((state) => [...state, model]);

        print("added a driver , ${ ref
            .read(availableDriversProvider).length} , ${ref
            .read(mainMarkersProvider).length} ");
      }
    } catch (e) {
      print("error data is $e");
      ElegantNotification.error(
          description: Text(
        "An Error Occurred $e",
        style: const TextStyle(color: Colors.black),
      )).show(context);
    }
  }
}
