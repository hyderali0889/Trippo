import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Model/driver_model.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Home_Screen/home_providers.dart';

import '../utils/error_notification.dart';

final globalFirestoreRepoProvider = Provider<FirestoreRepo>((ref) {
  return FirestoreRepo();
});

class FirestoreRepo {
  final geo = GeoFlutterFire();
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  void getDriverData(
      BuildContext context, WidgetRef ref, LatLng userPos) async {
    try {
      /// getting [DriverData] from [FirebaseFirestore]

      Stream<QuerySnapshot<Map<String, dynamic>>> drivers =
          db.collection("Drivers").snapshots();

      drivers.listen((event) {
        for (var driver in event.docs) {
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

          ref
              .read(homeScreenAvailableDriversProvider.notifier)
              .update((state) => [...state, model]);
        }
      });

      GeoFirePoint center =
          geo.point(latitude: userPos.latitude, longitude: userPos.longitude);

      Stream<List<DocumentSnapshot<Object?>>> allDriversStream = geo
          .collection(collectionRef: db.collection("Drivers"))
          .within(
              center: center, radius: 50, field: "driverLoc", strictMode: true);

      allDriversStream.listen((event) async {
        for (var driver in event) {
          if (driver["driverStatus"] == "Idle") {
            Marker marker = Marker(
                markerId: MarkerId(driver["Car Name"]),
                infoWindow: InfoWindow(
                  title: driver["Car Name"],
                ),
                position: LatLng(driver["driverLoc"]["geopoint"].latitude,
                    driver["driverLoc"]["geopoint"].longitude),
                icon: await BitmapDescriptor.fromAssetImage(
                    const ImageConfiguration(),
                    driver["Car Type"] == "Car"
                        ? "assets/imgs/sedan.png"
                        : driver["Car Type"] == "MotorCycle"
                            ? "assets/imgs/motorbike.png"
                            : "assets/imgs/suv.png"));

            ref
                .read(homeScreenMainMarkersProvider.notifier)
                .update((state) => {...state, marker});
          }
        }
      });
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void addUserRideRequestToDB(
      context, WidgetRef ref, String driverEmail) async {
    try {
      await db.collection(auth.currentUser!.email.toString()).add({
        "OriginLat":
            ref.read(homeScreenPickUpLocationProvider)!.locationLatitude,
        "OriginLng":
            ref.read(homeScreenPickUpLocationProvider)!.locationLongitude,
        "OriginAddress":
            ref.read(homeScreenPickUpLocationProvider)!.locationName,
        "destinationLat":
            ref.read(homeScreenDropOffLocationProvider)!.locationLatitude,
        "destinationLng":
            ref.read(homeScreenDropOffLocationProvider)!.locationLongitude,
        "destinationAddress":
            ref.read(homeScreenDropOffLocationProvider)!.locationName,
        "time": DateTime.now(),
        "userEmail": auth.currentUser!.email.toString(),
        "driverEmail": driverEmail
      });
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void nullifyUserRides(context) async {
    try {
      var data = await db.collection(auth.currentUser!.email.toString()).get();

      for (var alldata in data.docs) {
        alldata.reference.delete();
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void setDriverStatus(context, String driverEmail, String driverStatus) async {
    try {
      QuerySnapshot<Map<String, dynamic>> drivers = await db
          .collection("Drivers")
          .where("email", isEqualTo: driverEmail)
          .get();

      for (var driver in drivers.docs) {
        driver.reference.update({"driverStatus": driverStatus});
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
