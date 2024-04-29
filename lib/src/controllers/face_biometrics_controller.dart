import 'dart:async';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';


class FaceBiometricsController extends GetxController {
  final image = "".obs;
  final imageIsTaken = false.obs;
  final finalImageExistError = false.obs;
  final existErrorText = "".obs;
  final loading = false.obs;
  final error = false.obs;
  final errorMessage = "".obs;

  void staticImageValidation(InputImage inputImage) async {
    loading.value = true;
    finalImageExistError.value = false;
    existErrorText.value = "";
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
    final FaceDetector faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableContours: true,
        performanceMode: FaceDetectorMode.accurate
      ),
    );
    double? dxPosition = 0.0, dyPosition = 0.0, faceHeight = 0.0, faceWidth = 0.0;
    double? smileProbability = 0.0, rightEyeOpenProbability = 0.0, leftEyeOpenProbability = 0.0;
    double? headEulerPosX = 0.0, headEulerPosY = 0.0, headEulerPosZ = 0.0;
    double? glassesProbability = 0.0, otherObjectsProbability = 0.0;
    int? upperLipBottomDY = 0, lowerLipTopDY = 0;

    final faces = await faceDetector.processImage(inputImage);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null && faces.isNotEmpty) {
      for (final Face face in faces) {
        dxPosition = face.boundingBox.center.dx;
        dyPosition = face.boundingBox.center.dy;
        faceHeight = face.boundingBox.height;
        faceWidth = face.boundingBox.width;
        smileProbability = face.smilingProbability ?? 0;
        rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0;
        leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0;
        headEulerPosX = face.headEulerAngleX ?? 0;
        headEulerPosY = face.headEulerAngleY ?? 0;
        headEulerPosZ = face.headEulerAngleZ ?? 0;
        face.contours.values.forEach((element) {
          if(element != null) {
            if(element.type == FaceContourType.upperLipBottom) {
              upperLipBottomDY = element.points[5].y;
            } else if(element.type == FaceContourType.lowerLipTop) {
              lowerLipTopDY = element.points[5].y;
            }
          }
        });
      }

      for (ImageLabel label in labels) {
        final String text = label.label;
        // final int index = label.index;
        final double confidence = label.confidence;

        /* Glasses verification */
        if(text == "Glasses" || text == "Sunglasses" || text == "Goggles" || text == "Helmet") {
          switch(text){
            case "Glasses":
              if(confidence > glassesProbability!) {
                glassesProbability = confidence;
              }
              break;
            case "Sunglasses":
              if(confidence > glassesProbability!) {
                glassesProbability = confidence;
              }
              break;
            case "Goggles":
              if(confidence > glassesProbability!) {
                glassesProbability = confidence;
              }
              break;
            case "Helmet":
              if(confidence > glassesProbability!) {
                glassesProbability = confidence;
              }
              break;
          }
        } else if(text != "Glasses" && text != "Sunglasses" && text != "Goggles" && text != "Helmet") {
          Future.delayed(const Duration(milliseconds: 100)).then((value) => {
            glassesProbability = 0.0
          });
        }
      }
    } else if(faces.isEmpty) {
      finalImageExistError.value = true;
      existErrorText.value = "Position your face within the designated area";
    }

    if(faces.isNotEmpty) {
      /** Check distance between face and camera */
      if(faceHeight! < 320 && faceWidth! < 320) {
        /* Too far */
        finalImageExistError.value = true;
        existErrorText.value = "Move closer";
      } else if(faceHeight > 470 && faceWidth! > 470) {
        /* Too close */
        finalImageExistError.value = true;
        existErrorText.value = "Move further away";
      }
      /** Check face position */
      if((dxPosition! >= 280 && dxPosition <= 420) && (dyPosition! >= 460 && dyPosition <= 600)) {
        /* Success position */
      } else {
        /* Error position */
        finalImageExistError.value = true;
        existErrorText.value = "Position your face within the designated area";
      }
      /** Check is only one face */
      if(faces.length != 1) {
        finalImageExistError.value = true;
        existErrorText.value = "Make sure only you are visible in the photo";
      }
      /** Check if eyes are open */
      if((rightEyeOpenProbability! <= 0.7) || (leftEyeOpenProbability! <= 0.7)) {
        finalImageExistError.value = true;
        existErrorText.value = "Open your eyes please";
      }
      /** Check if the user smile */
      if(smileProbability! >= 0.2) {
        finalImageExistError.value = true;
        existErrorText.value = "Don't smile please";
      }
      /** Check if user head is centred in euler angle */
      if((headEulerPosX! >= -12 && headEulerPosX <= 16) && (headEulerPosZ! >= -7 && headEulerPosZ <= 7) && (headEulerPosY! >= -10 && headEulerPosY <= 10)) {
        /* Success position */
      } else {
        /* Error position */
        finalImageExistError.value = true;
        existErrorText.value = "Keep your head straight and look directly into the camera";
      }
      /** Check if don't wear glasses */
      if(glassesProbability! >= 0.82){
        finalImageExistError.value = true;
        existErrorText.value = "Remove head coverings and glasses";
      }
      /** Check if month is opened */
      if((lowerLipTopDY! - upperLipBottomDY!) >= 5) {
        finalImageExistError.value = true;
        existErrorText.value = "Close your month please";
      }
    }
    if(finalImageExistError.isFalse) {
      existErrorText.value = "";
    }
    loading.value = false;
  }
}