import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:next_vision_flutter_app/main.dart';
import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';


class Utilities {
  InputImage? inputImageFromCameraImage(CameraImage image, int cameraIndex) {
    final camera = cameras[cameraIndex];
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) {
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) {
      return null;
    }
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  void showCameraException({required CameraException error, required BuildContext context}) {
    logError(error.code, error.description);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${error.code}\n${error.description}')));
  }

  void showInSnackBar({required String message, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String? message) {
    if (kDebugMode) {
      log('Error: $code${message == null ? '' : '\nError Message: $message'}');
    }
  }

  void getPermissions() {
    Permission.manageExternalStorage.request();
    Permission.storage.request();
    Permission.mediaLibrary.request();
  }
}