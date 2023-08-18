import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_driver/View/Routes/routes.dart';
import 'package:trippo_driver/View/Screens/Auth_Screens/login_screen.dart';
import 'package:trippo_driver/View/Screens/Auth_Screens/register_screen.dart';
import 'package:trippo_driver/View/Screens/Nav_Screens/navigation_screen.dart';
import 'package:trippo_driver/View/Screens/Other_Screens/splash_screen.dart';

import '../Screens/Auth_Screens/driver_config.dart';

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
      name: Routes().driverConfig,
      path: '/${Routes().driverConfig}',
      builder: (BuildContext context, GoRouterState state) {
        return const DriverConfigsScreen();
      },
    ),
    GoRoute(
      name: Routes().navigationScreen,
      path: '/${Routes().navigationScreen}',
      builder: (BuildContext context, GoRouterState state) {
        return const NavigationScreen();
      },
    ),

    // Main Routes
  ];

