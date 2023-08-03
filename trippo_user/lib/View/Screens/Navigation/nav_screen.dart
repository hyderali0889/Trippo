import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_user/View/Screens/Main_Screens/home_screen.dart';
import 'package:trippo_user/View/Screens/Main_Screens/payment_screen.dart';
import 'package:trippo_user/View/Screens/Main_Screens/profile_screen.dart';
import 'package:trippo_user/View/Screens/Main_Screens/ratings_screen.dart';

final screenLocProvider = StateProvider<int>((ref) => 0);

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> pages = [
      const HomeScreen(),
      const PaymentScreen(),
      const RatingsScreen(),
      const ProfileScreen()
    ];

    return Scaffold(
      body: pages[ref.watch(screenLocProvider)],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 65, 64, 64),
        elevation: 10,
        indicatorColor: Colors.blueGrey,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: ref.watch(screenLocProvider),
        onDestinationSelected: (val) {
          ref.watch(screenLocProvider.notifier).update((state) => val);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home_filled,
              color: Colors.white,
            ),
            icon: Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            label: '',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.currency_bitcoin,
              color: Colors.white,
            ),
            icon: Icon(
              Icons.currency_bitcoin_outlined,
              color: Colors.white,
            ),
            label: '',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.star_purple500_outlined,
              color: Colors.white,
            ),
            icon: Icon(
              Icons.star_border_purple500_rounded,
              color: Colors.white,
            ),
            label: '',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            icon: Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
