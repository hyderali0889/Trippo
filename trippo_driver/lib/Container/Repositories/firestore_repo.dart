import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:trippo_driver/Model/driver_info_model.dart';

import '../utils/error_notification.dart';

final globalFirestoreRepoProvider = Provider<AddFirestoreData>((ref) {
  return AddFirestoreData();
});

class AddFirestoreData {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  void addDriversDataToFirestore(BuildContext context, String carName,
      String carPlateNum, String carType) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .set({
        "name": FirebaseAuth.instance.currentUser!.email!.split("@")[0],
        "email": FirebaseAuth.instance.currentUser!.email,
        "Car Name": carName,
        "Car Plate Num": carPlateNum,
        "Car Type": carType
      });
    } catch (e) {
      if(context.mounted){

      ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void getDriverDetails(BuildContext context) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> data = await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .get();

      DriverInfoModel driver = DriverInfoModel(
          auth.currentUser!.uid,
          data.data()?["name"],
          data.data()?["email"],
          data.data()?["Car Name"],
          data.data()?["Car Plate Num"],
          data.data()?["Car Type"]);

      print("data is ${driver.carType}");
    } catch (e) {
      if(context.mounted){

      ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void setDriverStatus(BuildContext context, String status) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .update({"driverStatus": status});
    } catch (e) {
   if(context.mounted){

      ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
  void setDriverLocationStatus(BuildContext context, GeoFirePoint? loc) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .update({"driverLoc": loc?.data});
    } catch (e) {
     if(context.mounted){

      ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
