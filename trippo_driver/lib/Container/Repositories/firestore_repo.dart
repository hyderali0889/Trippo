import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addDriverDataProvider = Provider<AddFirestoreData>((ref) {
  return AddFirestoreData();
});

class AddFirestoreData{
void addDriversDataToFirestore(BuildContext context, String carName,
    String carPlateNum, String carType) async {
  try {
    await FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.email.toString()).add({
      "email" : FirebaseAuth.instance.currentUser!.email,
      "Car Name" : carName,
      "Car Plate Num":carPlateNum,
      "Car Type": carType
    });
  } catch (e) {
    ElegantNotification.error(description: Text("An Error Occurred $e"))
        .show(context);
  }
}
}


