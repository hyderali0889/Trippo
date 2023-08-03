import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_driver/Container/Repositories/auth_repo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
          child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Text(
              "Profile",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontFamily: "bold", fontSize: 54),
            ),
            Consumer(
              builder: (context, ref, child) {
                return TextButton(
                    onPressed: () {
                      ref.watch(authRepoProvider).logOut(context);
                    },
                    child: const Text("Logout"));
              },
            )
          ],
        ),
      )),
    );
  }
}
