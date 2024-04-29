import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'coordinates_translator.dart';


class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation);
  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint faceStyle = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = Colors.yellow;
    final Paint borderStyle = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = Colors.lightGreenAccent;
    final Paint landMarksStyle = Paint()..style = PaintingStyle.stroke..strokeWidth = 6.0..color = Colors.purpleAccent;

    for (final Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
          translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
          translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
          translateY(face.boundingBox.bottom, rotation, size, absoluteImageSize),
        ),
        borderStyle,
      );

      void paintContour(FaceContourType type) {
        final faceContour = face.contours[type];
        if (faceContour?.points != null) {
          for (final Point point in faceContour!.points) {
            canvas.drawCircle(
              Offset(
                translateX(point.x.toDouble(), rotation, size, absoluteImageSize),
                translateY(point.y.toDouble(), rotation, size, absoluteImageSize)
              ), 1, faceStyle
            );
          }
        }
      }

      void paintLandmarks(FaceLandmarkType type) {
        final faceContour = face.landmarks[type];
        if (faceContour?.position != null) {
          canvas.drawCircle(
            Offset(
              translateX(faceContour!.position.x.toDouble(), rotation, size, absoluteImageSize),
              translateY(faceContour!.position.y.toDouble(), rotation, size, absoluteImageSize)
            ), 1, landMarksStyle
          );
        }
      }

      paintContour(FaceContourType.face);
      paintContour(FaceContourType.leftEyebrowTop);
      paintContour(FaceContourType.leftEyebrowBottom);
      paintContour(FaceContourType.rightEyebrowTop);
      paintContour(FaceContourType.rightEyebrowBottom);
      paintContour(FaceContourType.leftEye);
      paintContour(FaceContourType.rightEye);
      paintContour(FaceContourType.upperLipTop);
      paintContour(FaceContourType.upperLipBottom);
      paintContour(FaceContourType.lowerLipTop);
      paintContour(FaceContourType.lowerLipBottom);
      paintContour(FaceContourType.noseBridge);
      paintContour(FaceContourType.noseBottom);
      paintContour(FaceContourType.leftCheek);
      paintContour(FaceContourType.rightCheek);

      paintLandmarks(FaceLandmarkType.rightEar);
      paintLandmarks(FaceLandmarkType.leftEar);
      paintLandmarks(FaceLandmarkType.leftCheek);
      paintLandmarks(FaceLandmarkType.rightCheek);
      paintLandmarks(FaceLandmarkType.leftEye);
      paintLandmarks(FaceLandmarkType.rightEye);
      paintLandmarks(FaceLandmarkType.bottomMouth);
      paintLandmarks(FaceLandmarkType.noseBase);
      paintLandmarks(FaceLandmarkType.rightMouth);
      paintLandmarks(FaceLandmarkType.leftMouth);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize || oldDelegate.faces != faces;
  }
}
