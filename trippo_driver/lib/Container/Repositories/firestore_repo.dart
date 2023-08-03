import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../View/Routes/routes.dart';

final firestoreRepoProvider = Provider<FirestoreRepo>((ref) {
  return FirestoreRepo();
});

class FirestoreRepo {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addNameToFirestore(name, email, BuildContext context) async {
    try {
      await firestore.collection("Drivers").add({"name": name, "email": email});

      if (context.mounted) {
        context.goNamed(Routes().driverConfigs);
      }
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }

  void addUserDataToFirestore(
      String carName, String plateNum, String carType, context) async {
    try {
      QuerySnapshot<Map<String, dynamic>> drivers = await firestore
          .collection("Drivers")
          .where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      for (var driver in drivers.docs) {
        await driver.reference.update({
          "car Name": carName.toUpperCase(),
          "car Plate Number": plateNum,
          "Car Type": carType
        });
      }
    } catch (e) {
      ElegantNotification.error(description: Text("An Error Occurred $e"))
          .show(context);
    }
  }
}
