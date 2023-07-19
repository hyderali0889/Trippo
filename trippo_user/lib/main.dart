import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_user/firebase_options.dart';

import 'View/Routes/app_routes.dart';
import 'View/Themes/app_theme.dart';
Future<void> main()async{

   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options:DefaultFirebaseOptions.currentPlatform );
  runApp(const ProviderScope(child: MyApp()));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trippo',
      theme:appTheme,
    routerConfig: router,
    );
  }
}