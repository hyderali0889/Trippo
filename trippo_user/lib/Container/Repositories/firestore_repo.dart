import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Model/driver_model.dart';
import 'package:trippo_user/View/Screens/Main_Screens/home_screen.dart';

import '../utils/error_notification.dart';

final firestoreRepoProvider = Provider<FirestoreRepo>((ref) {
  return FirestoreRepo();
});

class FirestoreRepo {
  final geo = GeoFlutterFire();
  FirebaseFirestore db = FirebaseFirestore.instance;
  void getDriverData(
      BuildContext context, WidgetRef ref, LatLng userPos) async {
    try {
      /// getting [DriverData] from [FirebaseFirestore]
      QuerySnapshot<Map<String, dynamic>> drivers =
          await db.collection("Drivers").get();

       for (var driver in drivers.docs) {
        DriverModel model = DriverModel(
          driver.data()["Car Name"],
                driver.data()["Car Plate Num"],
            driver.data()["Car Type"],
            geo.point(latitude: driver.data()["driverLoc"]["geopoint"].latitude,
                longitude: driver.data()["driverLoc"]["geopoint"].longitude),
            driver.data()["driverStatus"],
            driver.data()["email"],
            driver.data()["name"]);

        if (driver.data()["driverStatus"] == "offline") {
          return;
        }

        ref
            .read(availableDriversProvider.notifier)
            .update((state) => [...state, model]);
      }


      GeoFirePoint center =
          geo.point(latitude: userPos.latitude, longitude: userPos.longitude);

      Stream<List<DocumentSnapshot<Object?>>> allDriversStream = geo
          .collection(collectionRef: db.collection("Drivers"))
          .within(center: center, radius: 50, field: "driverLoc", strictMode: true);

      allDriversStream.listen((event) async {

        for (var driver in event) {

          if (driver["driverStatus"] == "offline") {
            return;
          }
          Marker marker = Marker(
              markerId: MarkerId(driver["Car Name"]),
              infoWindow: InfoWindow(
                title: driver["Car Name"],
              ),
              position: LatLng(driver["driverLoc"]["geopoint"].latitude,
                  driver["driverLoc"]["geopoint"].longitude),              icon: await BitmapDescriptor.fromAssetImage(
                const ImageConfiguration(),
                "assets/imgs/sedan.png",
              ));
          ref
             .read(mainMarkersProvider.notifier)              .update((state) => {...state, marker});
        }
      });
    } catch (e) {
      ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }
}
