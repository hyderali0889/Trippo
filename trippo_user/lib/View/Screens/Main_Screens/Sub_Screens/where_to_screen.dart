import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Container/Repositories/place_details_repo.dart';
import 'package:trippo_user/Model/predicted_places.dart';
import '../../../../Container/Repositories/predicted_places_repo.dart';
import '../../../../Container/utils/error_notification.dart';

final predictedPlacesProvider =
    StateProvider.autoDispose<List<PredictedPlaces>?>((ref) {
  return null;
});

final whereToLoadingProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

class WhereToScreen extends StatefulWidget {
  const WhereToScreen({super.key, required this.controller});

  final GoogleMapController controller;

  @override
  State<WhereToScreen> createState() => _WhereToScreenState();
}

class _WhereToScreenState extends State<WhereToScreen> {
  final TextEditingController whereToController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xff1a3646),
        backgroundColor: const Color(0xff1a3646),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Where To Go",
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontFamily: "bold"),
        ),
      ),
      body: SafeArea(
          child: SizedBox(
        width: size.width,
        height: size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Consumer(
            builder: (context, ref, child) {
              return Column(
                children: [
                  SizedBox(
                    width: size.width * 0.9,
                    child: TextField(
                      onChanged: (e) {
                        if (e.length < 2) {
                          ref
                              .watch(predictedPlacesProvider.notifier)
                              .update((state) => null);
                        }
                        ref
                            .watch(predictedPlacesRepoProvider)
                            .getAllPredictedPlaces(e, context, ref);
                      },
                      controller: whereToController,
                      cursorColor: Colors.red,
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 14),
                      decoration: InputDecoration(
                          hintText: "Search Location",
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 14, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1))),
                    ),
                  ),
                  Expanded(
                    child: ref.watch(predictedPlacesProvider) == null
                        ? Container(
                            alignment: Alignment.center,
                            child: const Text(
                                "Please Write Something to start the search"))
                        : Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 15.0),
                            child: ref.watch(whereToLoadingProvider)
                                ? const CircularProgressIndicator.adaptive(
                                    backgroundColor: Colors.red,
                                  )
                                : ListView.separated(
                                    itemCount: ref
                                        .watch(predictedPlacesProvider)!
                                        .length,
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        height: 20,
                                        color: Colors.red,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () =>
                                            setDropOffLocation(ref, index),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            ref
                                                    .watch(predictedPlacesProvider)![
                                                        index]
                                                    .mainText ??
                                                "Loading ...",
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                  )
                ],
              );
            },
          ),
        ),
      )),
    );
  }

  /// user gets the [String] human readable address from the selected item from the [ListView] and the new data is
  /// shown on the screen as user types anything new in the text fiels

  void setDropOffLocation(WidgetRef ref, int index) async {
    try {
      await ref.read(placeDetailsRepoProvider).getAllPredictedPlaceDetails(
          ref.read(predictedPlacesProvider)![index].placeId!, context, ref , widget.controller);


    } catch (e) {
        ErrorNotification().showError(context,    "An Error Occurred $e");
    }
  }
}
