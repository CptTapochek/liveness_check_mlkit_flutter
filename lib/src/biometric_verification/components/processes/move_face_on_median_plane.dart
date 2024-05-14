import 'dart:async';
import 'dart:io';


class MoveFaceOnMedianPlane {
  static Map initDistanceRange = {"min": Platform.isIOS ? 580 : 400, "max": Platform.isIOS ? 750 : 570};
  static Map longDistanceRange = {"min": Platform.isIOS ? 900 : 620, "max": Platform.isIOS ? 1000 : 770};
  static Map shortDistanceRange = {"min": Platform.isIOS ? 1200 : 900, "max": Platform.isIOS ? 1350 : 1100};
  static List turnHeadDirections = <TurnHeadDirections>[TurnHeadDirections.left, TurnHeadDirections.right];
  static Map headTurnRange = {"right": 42, "left": -42};
  static int waitingTime = 5;

  void calibrateFaceDistance({
    required double faceWidth,
    required double faceHeight,
    required double headPosY,
    CurrentPhase currentPhase = CurrentPhase.initFaceDistance,
    CurrentProcess currentProcess = CurrentProcess.longDistance,
    required Function callBack,
    required bool errorIsActive,
    required TurnHeadDirections lookDirection,
  }) {
    String callbackText = "";
    CurrentPhase _currentPhase = currentPhase;
    CurrentProcess _currentProcess = currentProcess;
    double progress = 0.0;
    bool progressIndicator = false;

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
        progressIndicator = true;
        if(_currentProcess == CurrentProcess.longDistance) {
          if((faceHeight > longDistanceRange["min"] && faceWidth > longDistanceRange["min"]) && (faceHeight < longDistanceRange["max"] && faceWidth < longDistanceRange["max"])) {
            callbackText = "Move face closer";
            if(!errorIsActive) {
              _currentPhase = CurrentPhase.turnHead;
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
              _currentPhase = CurrentPhase.wait;  //Success for short distance
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
      case CurrentPhase.transition:
        _currentProcess = CurrentProcess.shortDistance;
        if(faceHeight < shortDistanceRange["min"] && faceWidth < shortDistanceRange["min"]) {
          callbackText = "Move face closer";
          progress = (faceWidth / shortDistanceRange["min"] + faceHeight / shortDistanceRange["min"]) / 2;
        } else if(faceHeight > shortDistanceRange["max"] && faceWidth > shortDistanceRange["max"]) {
          callbackText = "Move face back";
          progress = (faceWidth / shortDistanceRange["max"] + faceHeight / shortDistanceRange["max"]) / 2;
        } else {
          callbackText = "Wait please";
          progress = (faceWidth / shortDistanceRange["max"] + faceHeight / shortDistanceRange["max"]) / 2;
        }
        break;
      case CurrentPhase.turnHead:
        progressIndicator = true;
        switch(lookDirection) {
          case TurnHeadDirections.left:
            callbackText = "Look left";
            progress = headPosY/headTurnRange["left"];
            if(headPosY > 0) {
              progress = 0;
            }
            if(headPosY <= headTurnRange["left"]) {
              _currentPhase = CurrentPhase.transition;
            }
            break;
          case TurnHeadDirections.right:
            callbackText = "Look right";
            progress = headPosY/headTurnRange["right"];
            if(headPosY < 0) {
              progress = 0;
            }
            if(headPosY >= headTurnRange["right"]) {
              _currentPhase = CurrentPhase.transition;
            }
            break;
        }
        break;
      case CurrentPhase.wait:
        progressIndicator = false;
        progress = 1.0;
        callbackText = "Hold still";
        break;
      case CurrentPhase.endCalibration:
        progressIndicator = false;
        callbackText = "End";
        break;
    }

    callBack({
      "text": callbackText,
      "phase": _currentPhase,
      "process": _currentProcess,
      "progress": progress,
      "progressIndicator": progressIndicator,
      "lookDirection": lookDirection,
      "waitingTime": waitingTime
    });
  }

  Future countDownWaitingProcess({required Function callBack}) async {
    int waitingTimeInSec = waitingTime;
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      waitingTimeInSec--;
      callBack(waitingTimeInSec);
      if(waitingTimeInSec == 0) {
        timer.cancel();
      }
    });
  }
}

enum CurrentPhase {
  initFaceDistance,
  calibrateFace,
  transition,
  turnHead,
  wait,
  endCalibration
}

enum CurrentProcess {
  longDistance,
  shortDistance,
}

enum TurnHeadDirections {
  left,
  right
}