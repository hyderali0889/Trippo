import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_user/View/Routes/routes.dart';
import 'package:trippo_user/View/Screens/Auth_Screens/Login_Screen/login_screen.dart';
import 'package:trippo_user/View/Screens/Auth_Screens/Register_Screen/register_screen.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Home_Screen/home_screen.dart';
import 'package:trippo_user/View/Screens/Main_Screens/Sub_Screens/Where_To_Screen/where_to_screen.dart';

import 'package:trippo_user/View/Screens/Other_Screens/Splash_Screen/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');



final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/${Routes().splash}',



  routes:allRoutes
);


final List<RouteBase> allRoutes =[

  // Other Screen Routes

    GoRoute(
      name: Routes().splash,
      path: '/${Routes().splash}',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),

    // Auth Routes
    GoRoute(
      name: Routes().login,
      path: '/${Routes().login}',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      name: Routes().register,
      path: '/${Routes().register}',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      name: Routes().home,
      path: '/${Routes().home}',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),

    // Main Routes


  // Main Sub Routes
 GoRoute(

      name: Routes().whereTo,
      path: '/${Routes().whereTo}',

      builder: (BuildContext context, GoRouterState state) {

        return  WhereToScreen( controller:state.extra as GoogleMapController ,);
      },
    ),


  ];

