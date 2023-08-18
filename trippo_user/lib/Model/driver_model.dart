// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:geoflutterfire2/geoflutterfire2.dart';

class DriverModel {
  String carName;
  String carPlateNum;
  String carType;
  GeoFirePoint driverLoc;
  String driverStatus;
  String email;
  String name;
  DriverModel(
     this.carName,
     this.carPlateNum,
     this.carType,
     this.driverLoc,
     this.driverStatus,
     this.email,
     this.name,
  );
}
