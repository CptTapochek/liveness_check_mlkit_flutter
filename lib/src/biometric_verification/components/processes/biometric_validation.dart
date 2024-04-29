import 'dart:io';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/move_face_on_median_plane.dart';


class BiometricValidation {
  static Map longFacePosRange = {
    "minDX": Platform.isIOS ? 400 : 230, "maxDX": Platform.isIOS ? 700 : 480,
    "minDY": Platform.isIOS ? 620 : 400, "maxDY": Platform.isIOS ? 1050 : 660,
  };
  static Map shortFacePosRange = {
    "minDX": Platform.isIOS ? 350 : 220, "maxDX": Platform.isIOS ? 700 : 480,
    "minDY": Platform.isIOS ? 750 : 450, "maxDY": Platform.isIOS ? 1200 : 800,
  };
  static Map headRange = {
    "minX": -20, "maxX": 20, "minY": -23, "maxY": 23, "minZ": -15, "maxZ": 15,
  };

  void headPosition({required double posX, required double posZ, required double posY, required Function callBack}) {
    bool existError = true;
    if((posX >= headRange["minX"] && posX <= headRange["maxX"]) && (posZ >= headRange["minZ"] && posZ <= headRange["maxZ"]) && (posY >= headRange["minY"] && posY <= headRange["maxY"])) {
      /* Success position */
      existError = false;
    }
    callBack({
      "error": existError,
      "text": "Keep your head straight and look directly into the camera"
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
}