import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AppBarState {
  AppBar light = AppBar(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    toolbarHeight: 0,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
    ),
  );

  AppBar dark = AppBar(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    toolbarHeight: 0,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ),
  );
}