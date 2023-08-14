import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      bodySmall:
          TextStyle(color: Colors.white, fontFamily: "regular", fontSize: 16),
      bodyMedium:
          TextStyle(color: Colors.white, fontFamily: "medium", fontSize: 20),
      bodyLarge:
          TextStyle(color: Colors.white, fontFamily: "bold", fontSize: 22),
    ).apply());
