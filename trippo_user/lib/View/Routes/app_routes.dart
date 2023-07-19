

import 'package:go_router/go_router.dart';
import 'package:trippo_user/View/Routes/routes.dart';
import '../Screens/home_screen.dart';

 final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: "/${Routes().home}",
      name: Routes().home,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
