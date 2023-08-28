import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverConfigDropDownProvider = StateProvider.autoDispose<String?>((ref) => "SUV");
final driverConfigIsLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);