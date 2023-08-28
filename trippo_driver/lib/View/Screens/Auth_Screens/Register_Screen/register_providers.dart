import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerIsLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
