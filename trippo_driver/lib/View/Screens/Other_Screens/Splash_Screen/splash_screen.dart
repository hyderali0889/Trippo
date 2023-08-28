import 'package:flutter/material.dart';
import 'package:trippo_driver/View/Screens/Other_Screens/Splash_Screen/splash_logics.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    SplashLogics().checkPermissions(context);
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
          child: SizedBox(
              width: size.width,
              height: size.height,
              child: Center(
                child: Text(
                  "Trippo",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontFamily: "bold", fontSize: 54),
                ),
              ))),
    );
  }
}
