import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginIsLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
