import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
//import 'package:trippo_driver/Container/Repositories/firestore_repo.dart';
import 'package:trippo_driver/View/Components/all_components.dart';
import 'package:trippo_driver/View/Routes/routes.dart';

import '../../../Container/Repositories/firestore_repo.dart';

final dropDownProvider = StateProvider.autoDispose<String?>((ref) => "SUV");
final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class DriverConfigsScreen extends StatefulWidget {
  const DriverConfigsScreen({super.key});

  @override
  State<DriverConfigsScreen> createState() => _DriverConfigsScreenState();
}

class _DriverConfigsScreenState extends State<DriverConfigsScreen> {
  final TextEditingController carNameController = TextEditingController();
  final TextEditingController plateNumController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
          child: SizedBox(
        width: size.width,
        height: size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Text(
                "Driver Config",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontFamily: "bold", fontSize: 20),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Components().returnTextField(carNameController,
                              context, false, "Please Enter Car Name"),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Components().returnTextField(
                                plateNumController,
                                context,
                                false,
                                "Please Enter Car Plate Number"),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SizedBox(
                                width: size.width * 0.7,
                                child: DropdownButton(
                                  value: ref.watch(dropDownProvider),
                                  onChanged: (val) {
                                    ref
                                        .watch(dropDownProvider.notifier)
                                        .update((state) => val);
                                  },
                                  dropdownColor: Colors.black45,
                                  isExpanded: true,
                                  underline: Container(),
                                  hint: Text(
                                    "Select Car",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            fontFamily: "medium", fontSize: 14),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: "SUV",
                                        child: Text(
                                          "SUV",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontFamily: "medium",
                                                  fontSize: 14),
                                        )),
                                    DropdownMenuItem(
                                        value: "Car",
                                        child: Text(
                                          "Car",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontFamily: "medium",
                                                  fontSize: 14),
                                        )),
                                    DropdownMenuItem(
                                        value: "MotorCycle",
                                        child: Text(
                                          "MotorCycle",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontFamily: "medium",
                                                  fontSize: 14),
                                        )),
                                  ],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: Consumer(
                              builder: (context, ref, child) {
                                return InkWell(
                                    onTap: ref.watch(isLoadingProvider)
                                        ? null
                                        : () => sendDataToFirestore(ref),
                                    child: Components().mainButton(
                                        size,
                                        ref.watch(isLoadingProvider)
                                            ? "Loading ..."
                                            : "Submit Data",
                                        context,
                                        ref.watch(isLoadingProvider)
                                            ? Colors.grey
                                            : Colors.blue));
                              },
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  void sendDataToFirestore(ref) async {
    try {
      if (carNameController.text.isEmpty || plateNumController.text.isEmpty) {
        ElegantNotification.error(
                height: 50,
                description:
                    const Text("Please Enter Car Name and Plate Number"))
            .show(context);
        return;
      }
      ref.watch(isLoadingProvider.notifier).update((state) => true);

      ref.watch(addDriverDataProvider).addDriversDataToFirestore(
          context,
          carNameController.text.trim(),
          plateNumController.text.trim(),
          ref.watch(dropDownProvider)!);

      if (context.mounted) {
        context.goNamed(Routes().home);
      }
    } catch (e) {
      ref.watch(isLoadingProvider.notifier).update((state) => false);
      ElegantNotification.error(description: Text("An Error Occurred $e" , style:const TextStyle(color: Colors.black)))
          .show(context);
    }
  }
}
