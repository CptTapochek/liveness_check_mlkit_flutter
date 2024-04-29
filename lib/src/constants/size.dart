import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AppSize {
  const AppSize();

  double screenH() {
    return Get.height;
  }

  double screenW() {
    return Get.width;
  }

  double flex(double size) {
    if(size < 1000) {
      return appSizeConst[size.toInt()];
    } else {
      return screenW() / designWidth * size;
    }
  }

  double fontFlex(double size) {
    if(size < 1000) {
      return fontSizeConst[size.toInt()];
    } else {
      double scaleFactor = getScaleFactor();
      return screenW() / designWidth * size * scaleFactor;
    }
  }

  void initAppSize() {
    double scaleFactor = getScaleFactor();
    appSizeConst = [];
    fontSizeConst = [];
    for(int index = 0; index <= 1000; index++) {
      appSizeConst.add(double.parse((screenW() / designWidth * index).toStringAsFixed(2)));
      fontSizeConst.add(double.parse((screenW() / designWidth * index * scaleFactor).toStringAsFixed(2)));
    }
  }

  double getScaleFactor() {
    if(Get.textScaleFactor > 2.0) {
      return 2.0 * 0.81;
    } else if(Get.textScaleFactor > 1.3 && Get.textScaleFactor <= 2.0) {
      return Get.textScaleFactor * 0.81;
    } else {
      return Get.textScaleFactor;
    }
  }

  bool checkScaleFactor() {
    double scaleFactor = getScaleFactor();
    if(fontFlex(16) != double.parse((screenW() / designWidth * 16 * scaleFactor).toStringAsFixed(2))) {
      print("Different value");
      factorSize = const AppSize().getScaleFactor();
      initAppSize();
      return true;
    }
    return false;
  }
}

List appSizeConst = [];
List fontSizeConst = [];
Size appSize = Get.size;
double factorSize = const AppSize().getScaleFactor();
const double designWidth = 320;