import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/Container/Repositories/predicted_places_repo.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Sub_Screens/Where_To_Screen/where_to_logics.dart';

import 'where_to_providers.dart';

class WhereToScreen extends StatefulWidget {
  const WhereToScreen({super.key, required this.controller});

  final GoogleMapController controller;

  @override
  State<WhereToScreen> createState() => _WhereToScreenState();
}

class _WhereToScreenState extends State<WhereToScreen> {
  final TextEditingController whereToController = TextEditingController();

  late NavigatorState _navigator;

  @override
  void didChangeDependencies() {
    _navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

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
                              .watch(whereToPredictedPlacesProvider.notifier)
                              .update((state) => null);
                        }
                        ref
                            .watch(globalPredictedPlacesRepoProvider)
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
                    child: ref.watch(whereToPredictedPlacesProvider) == null
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
                                        .watch(whereToPredictedPlacesProvider)!
                                        .length,
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        height: 20,
                                        color: Colors.red,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () async {
                                          try {
                                            await WhereToLogics()
                                                .setDropOffLocation(
                                                    context,
                                                    ref,
                                                    widget.controller,
                                                    index);

                                            _navigator.pop();
                                          } catch (e) {
                                            print(e);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            ref
                                                    .watch(whereToPredictedPlacesProvider)![
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
}
