import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';


class FraudValidation {
  static int sessionTimeOutInSec = kDebugMode ? 400 : 30;
  static Map eyesMovingDeviationLimit = {"min": 10.0};
  static Map headMovingDeviationLimit = {"max": 2.0};
  static Map fraudObjectsMinConfidence = {"mobilePhone": 40.0, "paper": 30.0, "television": 40.0};
  static int maximalFraudAttempts = 10;

  void getDeviation({required List<double> dataSet, required Function callBack}) {
    double mean = dataSet.reduce((value, element) => value + element) / dataSet.length;
    double sumOf = 0.0;

    for(double data in dataSet) {
      sumOf += pow(data - mean, 2);
    }
    double deviation = sqrt(sumOf / (dataSet.length - 1));
    callBack(deviation);
  }

  void sessionTimer({required Function callBack}) {
    int seconds = sessionTimeOutInSec;
    const oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec, (Timer timer) {
        if (seconds == 0) {
          timer.cancel();
        } else {
          seconds--;
          callBack(seconds);
        }
      },
    );
  }

  void eyesMovingDeviationCheck({required double deviation, required Function callBack}) {
    bool error = false;
    if(deviation < eyesMovingDeviationLimit["min"]) {
      error = true;
    }
    callBack(error);
  }

  void headMovingDeviationCheck({required double deviation, required Function callBack}) {
    bool error = false;
    if(deviation > headMovingDeviationLimit["max"]) {
      error = true;
    }
    callBack(error);
  }

  void fraudObjectsDetection({required Map fraudObj, required Function callBack}) {
    int countedErrors = 0;
    fraudObjectsMinConfidence.forEach((key, value) {
      if(fraudObj[key] != null) {
        if(fraudObj[key] * 100 >= value) {
          countedErrors++;
        }
      }
    });
    callBack(countedErrors);
  }
}