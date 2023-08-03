import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_driver/View/Routes/routes.dart';
import 'package:trippo_driver/View/Screens/Auth_Screens/driver_config.dart';
import 'package:trippo_driver/View/Screens/Auth_Screens/login_screen.dart';
import 'package:trippo_driver/View/Screens/Auth_Screens/register_screen.dart';
import 'package:trippo_driver/View/Screens/Other_Screens/splash_screen.dart';
import '../Screens/Navigation/nav_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');



final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/${Routes().splash}',
  debugLogDiagnostics: true,

  
  routes: <RouteBase>[
    GoRoute(
      name: Routes().splash,
      path: '/${Routes().splash}',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
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
      name: Routes().driverConfigs,
      path: '/${Routes().driverConfigs}',
      builder: (BuildContext context, GoRouterState state) {
        return const DriverConfigsScreen();
      },
    ),

    GoRoute(

      name: Routes().navigation,
      path: '/${Routes().navigation}',
      builder: (BuildContext context, GoRouterState state) {
        return const NavigationScreen(

        );
      },
    ),

  ],
);

