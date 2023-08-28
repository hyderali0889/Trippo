import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_user/Model/predicted_places.dart';

final whereToPredictedPlacesProvider =
    StateProvider.autoDispose<List<PredictedPlaces>?>((ref) {
  return null;
});

final whereToLoadingProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});
