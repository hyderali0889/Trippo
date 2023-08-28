
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_driver/Model/direction_model.dart';

final homeScreenDriversLocationProvider = StateProvider<Direction?>((ref) {
  return null;
});

final homeScreenMainPolylinesProvider = StateProvider<Set<Polyline>>((ref) {
  return {};
});

final homeScreenMainMarkersProvider = StateProvider<Set<Marker>>((ref) {
  return {};
});

final homeScreenMainCirclesProvider = StateProvider<Set<Circle>>((ref) {
  return {};
});

final homeScreenIsDriverActiveProvider = StateProvider<bool>((ref) {
  return false;
});