import 'dart:io';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/move_face_on_median_plane.dart';


class BiometricValidation {
  static Map longFacePosRange = {
    "minDX": Platform.isIOS ? 350 : 180, "maxDX": Platform.isIOS ? 750 : 530,
    "minDY": Platform.isIOS ? 570 : 350, "maxDY": Platform.isIOS ? 1100 : 710,
  };
  static Map shortFacePosRange = {
    "minDX": Platform.isIOS ? 300 : 170, "maxDX": Platform.isIOS ? 750 : 530,
    "minDY": Platform.isIOS ? 700 : 400, "maxDY": Platform.isIOS ? 1250 : 850,
  };
  static Map headRange = {
    "minX": -20, "maxX": 25, "minY": -25, "maxY": 25, "minZ": -15, "maxZ": 15,
  };

  void headPosition({required double posX, required double posZ, required double posY, required Function callBack, required bool turnHeadPhase}) {
    bool existError = true;
    String errorText = "";
    if(turnHeadPhase) {
      if((posX >= headRange["minX"] && posX <= headRange["maxX"]) && (posZ >= headRange["minZ"] && posZ <= headRange["maxZ"])) {
        existError = false; // Success position
      } else {
        errorText = "Wrong direction";
      }
    } else {
      if((posX >= headRange["minX"] && posX <= headRange["maxX"]) && (posZ >= headRange["minZ"] && posZ <= headRange["maxZ"]) && (posY >= headRange["minY"] && posY <= headRange["maxY"])) {
        existError = false; // Success position
      } else {
        errorText = "Keep your head straight and look directly into the camera";
      }
    }
    callBack({
      "error": existError,
      "text": errorText
    });
  }

  void facePosition({required double dx, required double dy, required CurrentProcess currentProcess, required Function callBack}) {
    final Map process = currentProcess == CurrentProcess.shortDistance ? shortFacePosRange : longFacePosRange;
    bool existError = true;

    if((dx >= process["minDX"] && dx <= process["maxDX"]) && (dy >= process["minDY"] && dy <= process["maxDY"])) {
      /* Success position */
      existError = false;
    }
    callBack({
      "error": existError,
      "text": "Position your face within the designated area"
    });
  }

  void eyeOpen({required double right, required double left, required Function callBack}) async {
    bool existError = false;

    if(!(right > 0.85 && left > 0.85)) {
      existError = true;
    }
    callBack({
      "error": existError,
      "text": "Do not keep your eyes closed"
    });
  }
}