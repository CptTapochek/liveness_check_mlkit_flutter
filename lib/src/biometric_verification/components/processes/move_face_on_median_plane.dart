import 'dart:io';


class MoveFaceOnMedianPlane {
  static Map initDistanceRange = {"min": Platform.isIOS ? 580 : 400, "max": Platform.isIOS ? 750 : 570};
  static Map longDistanceRange = {"min": Platform.isIOS ? 900 : 620, "max": Platform.isIOS ? 1000 : 770};
  static Map shortDistanceRange = {"min": Platform.isIOS ? 1200 : 900, "max": Platform.isIOS ? 1350 : 1100};

  void calibrateFaceDistance({
    required double faceWidth,
    required double faceHeight,
    CurrentPhase currentPhase = CurrentPhase.initFaceDistance,
    CurrentProcess currentProcess = CurrentProcess.longDistance,
    required Function callBack,
    required bool errorIsActive,
  }) {
    String callbackText = "";
    CurrentPhase _currentPhase = currentPhase;
    CurrentProcess _currentProcess = currentProcess;
    double progress = 0.0;

    switch(_currentPhase) {
      case CurrentPhase.initFaceDistance:
        _currentProcess = CurrentProcess.longDistance;
        if(faceHeight > initDistanceRange["min"] && faceWidth > initDistanceRange["min"]) {
          callbackText = "Move face closer";
        } else if(faceHeight <= initDistanceRange["max"] && faceWidth <= initDistanceRange["max"]) {
          callbackText = "Move face back";
        }
        _currentPhase = CurrentPhase.calibrateFace;
        break;
      case CurrentPhase.calibrateFace:
        if(_currentProcess == CurrentProcess.longDistance) {
          if((faceHeight > longDistanceRange["min"] && faceWidth > longDistanceRange["min"]) && (faceHeight < longDistanceRange["max"] && faceWidth < longDistanceRange["max"])) {
            callbackText = "Move face closer";
            if(!errorIsActive) {
              _currentProcess = CurrentProcess.shortDistance; //Success for long distance
            }
            progress = 1.0;
          } else if(faceHeight < longDistanceRange["min"] && faceWidth < longDistanceRange["min"]) {
            callbackText = "Move face closer";
            progress = (faceWidth / longDistanceRange["min"] + faceHeight / longDistanceRange["min"]) / 2;
          } else if(faceHeight > longDistanceRange["max"] && faceWidth > longDistanceRange["max"]) {
            callbackText = "Move face back";
            progress = (faceWidth / longDistanceRange["max"] + faceHeight / longDistanceRange["max"]) / 2;
          }
        } else if(_currentProcess == CurrentProcess.shortDistance) {
          if((faceHeight > shortDistanceRange["min"] && faceWidth > shortDistanceRange["min"]) && (faceHeight < shortDistanceRange["max"] && faceWidth < shortDistanceRange["max"])) {
            if(!errorIsActive) {
              _currentPhase = CurrentPhase.loading;  //Success for short distance
              _currentProcess = CurrentProcess.loading;
            }
            callbackText = "Hold still";
            progress = 1.0;
          } else if(faceHeight < shortDistanceRange["min"] && faceWidth < shortDistanceRange["min"]) {
            callbackText = "Move face closer";
            progress = (faceWidth / shortDistanceRange["min"] + faceHeight / shortDistanceRange["min"]) / 2;
          } else if(faceHeight > shortDistanceRange["max"] && faceWidth > shortDistanceRange["max"]) {
            callbackText = "Move face back";
            progress = (faceWidth / shortDistanceRange["max"] + faceHeight / shortDistanceRange["max"]) / 2;
          }
        }
        break;
      case CurrentPhase.loading:
        progress = 1.0;
        callbackText = "Hold still";
        break;
    }

    callBack({
      "text": callbackText,
      "phase": _currentPhase,
      "process": _currentProcess,
      "progress": progress
    });
  }
}

enum CurrentPhase {
  initFaceDistance,
  calibrateFace,
  loading,
}

enum CurrentProcess {
  longDistance,
  shortDistance,
  loading
}