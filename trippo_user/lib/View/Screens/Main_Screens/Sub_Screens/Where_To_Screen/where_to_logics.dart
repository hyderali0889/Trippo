import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Container/Repositories/place_details_repo.dart';
import 'package:trippo_user/Container/utils/error_notification.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Sub_Screens/Where_To_Screen/where_to_providers.dart';

class WhereToLogics {
  /// user gets the [String] human readable address from the selected item from the [ListView] and the new data is
  /// shown on the screen as user types anything new in the text fiels

  Future<dynamic> setDropOffLocation(BuildContext context, WidgetRef ref,
      GoogleMapController controller, int index) async {
    try {
      await ref
          .read(globalPlaceDetailsRepoProvider)
          .getAllPredictedPlaceDetails(
              ref.read(whereToPredictedPlacesProvider)![index].placeId!,
              context,
              ref,
              controller);


    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
