import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/camera_view.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/fraud_validation.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/move_face_on_median_plane.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/biometric_validation.dart';
import 'package:next_vision_flutter_app/src/constants/app_bar_state.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/painters/face_detector_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';



class Liveness extends StatefulWidget {
  const Liveness({
    Key? key,
    this.faceTrackingID = 0,
  }) : super(key: key);
  final int faceTrackingID;

  @override
  State<Liveness> createState() => _LivenessState();
}

class _LivenessState extends State<Liveness> {
  final _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.25));
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableTracking: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _canProcess = true, _isBusy = false;
  final bool _debugMode = kDebugMode;
  CustomPaint? _customPaint;
  double? _dxPosition = 0.0, _dyPosition = 0.0, _faceHeight = 0.0, _faceWidth = 0.0;
  double? _rightEyeOpenProbability = 0.0, _leftEyeOpenProbability = 0.0, eyeMovingDeviation = 0.0;
  List<double> eyesMovingDataSet = [], headZPosDataSet = [];
  double? _headEulerPosX = 0.0, _headEulerPosY = 0.0, _headEulerPosZ = 0.0, headZPosDeviation = 0.0;
  int? _upperLipBottomDY = 0, _lowerLipTopDY = 0;
  Map _distanceCalibration = {};
  int? _trackingID = 0;
  bool _errorIsActivated = false;
  bool _existFace = false;
  bool waitingTimerStarted = false;
  String _errorText = "";
  Map fraudParams = {"mobilePhone": 0.0, "poster": 0.0};

  @override
  void initState() {
    _distanceCalibration = {
      "process": CurrentProcess.longDistance,
      "phase": CurrentPhase.initFaceDistance,
      "text": "",
      "progress": 0.0,
      "progressIndicator": false,
      "waitingTime": MoveFaceOnMedianPlane.waitingTime
    };
    super.initState();
  }

  Future errorActivator({required bool error, required String text}) async {
    if(!_errorIsActivated && error) {
      setState(() {
        if(mounted) {
          _errorIsActivated = true;
          _errorText = text;
        }
      });
      await Future.delayed(const Duration(milliseconds: 1400), () {
        if(mounted) {
          setState(() {
            _errorIsActivated = false;
            _errorText = "";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarState().dark,
      body: CameraView(
        onImage: (inputImage) {
          processImage(inputImage);
        },
        graphData: ((_rightEyeOpenProbability ?? 0.0) + (_leftEyeOpenProbability ?? 0.0)) / 2,
        // graphData: _headEulerPosZ ?? 0.0,
        distanceCalibration: _distanceCalibration,
        customPaint: _customPaint,
        initialDirection: CameraLensDirection.front,
        error: _errorIsActivated,
        errorText: _errorText,
        debugMode: _debugMode,
        debugValuesList: [
          {"title":"Face tracking ID", "value": _trackingID},
          {"title":"Position DX", "value": _dxPosition?.toStringAsFixed(2)},
          {"title":"Position DY", "value": _dyPosition?.toStringAsFixed(2)},
          {"title":"Face height", "value": _faceHeight?.toStringAsFixed(2)},
          {"title":"Face width", "value": _faceWidth?.toStringAsFixed(2)},
          {"title":"Left eye is open", "value": _leftEyeOpenProbability?.toStringAsFixed(3)},
          {"title":"Right eye is open", "value": _rightEyeOpenProbability?.toStringAsFixed(3)},
          {"title":"Head angle X", "value": _headEulerPosX?.toStringAsFixed(3)},
          {"title":"Head angle Y", "value": _headEulerPosY?.toStringAsFixed(3)},
          {"title":"Head angle Z", "value": _headEulerPosZ?.toStringAsFixed(3)},
          {"title":"Month open value", "value": (_lowerLipTopDY! - _upperLipBottomDY!)},
          {"title":"Attack suspect", "value": fraudParams["mobilePhone"].toStringAsFixed(2)},
          {"title":"BG issues", "value": fraudParams["poster"].toStringAsFixed(2)},
          {"title":"Exist Faces", "value": _existFace},
          {"title":"Eye moving deviation", "value": eyeMovingDeviation?.toStringAsFixed(2)},
          {"title":"Head z pos deviation", "value": headZPosDeviation?.toStringAsFixed(2)},
        ],
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final faces = await _faceDetector.processImage(inputImage);
    final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

    if(_debugMode) {
      final painter = FaceDetectorPainter(faces, inputImage.metadata!.size, inputImage.metadata!.rotation);
      _customPaint = CustomPaint(painter: painter);
    }

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null && faces.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if(mounted) {
          setState(() => _existFace = true);
        }
      });
      for (final Face face in faces) {
        _dxPosition = face.boundingBox.center.dx;
        _dyPosition = face.boundingBox.center.dy;
        _faceHeight = face.boundingBox.height;
        _faceWidth = face.boundingBox.width;
        _rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0;
        _leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0;
        ///dataSet = ((rightEye + leftEye) / 2) * 100 -> round to 2 decimals
        eyesMovingDataSet.add(double.parse(((((_rightEyeOpenProbability ?? 0.0) + (_leftEyeOpenProbability ?? 0.0)) / 2) * 100).toStringAsFixed(2)));
        _headEulerPosX = face.headEulerAngleX ?? 0;
        _headEulerPosY = face.headEulerAngleY ?? 0;
        _headEulerPosZ = face.headEulerAngleZ ?? 0;
        headZPosDataSet.add(double.parse((face.headEulerAngleZ ?? 0.0).toStringAsFixed(2)));

        face.contours.values.forEach((element) {
          if(element != null) {
            if(element.type == FaceContourType.upperLipBottom) {
              _upperLipBottomDY = element.points[5].y;
            } else if(element.type == FaceContourType.lowerLipTop) {
              _lowerLipTopDY = element.points[5].y;
            }
          }
        });
        _trackingID = face.trackingId;
      }

      for (ImageLabel label in labels) {
        final String text = label.label;
        final int index = label.index;
        final double confidence = label.confidence;

        // print("---text: $text\n---index: $index \n---confidence: $confidence");
        // if(text == "Mobile phone") {
        //   print("---text: Not real face prob\n---index: $index \n---confidence: $confidence");
        // }

        if(text == "Mobile phone") {
          fraudParams["mobilePhone"] = confidence;
          ///error++
        } else {
          fraudParams["mobilePhone"] = 0.1;
        }
        if(text == "Poster") {
          fraudParams["poster"] = confidence;
          ///error++
        } else {
          fraudParams["poster"] = 0.1;
        }
        if(text == "Paper" && confidence >= 0.35) {
          ///error++
        }
      }
    } else if(faces.isEmpty) {
      errorActivator(error: true, text: "Face not detected");
      if(mounted) {
        setState(() => _existFace = false);
      }
    }

    if(mounted && faces.isNotEmpty) {
      setState(() {
        MoveFaceOnMedianPlane().calibrateFaceDistance(
          faceWidth: _faceWidth ?? 0.0,
          faceHeight: _faceHeight ?? 0.0,
          currentPhase: _distanceCalibration["phase"] ?? CurrentPhase.initFaceDistance,
          currentProcess: _distanceCalibration["process"] ?? CurrentProcess.longDistance,
          errorIsActive: _errorIsActivated,
          callBack: (response) {
            if(_distanceCalibration["phase"] == CurrentPhase.wait) {
              if(!waitingTimerStarted) {
                MoveFaceOnMedianPlane().countDownWaitingProcess(
                  callBack: (int second) {
                    _distanceCalibration["waitingTime"] = second;
                    if(second == MoveFaceOnMedianPlane.waitingTime) {
                      _distanceCalibration["phase"] = CurrentPhase.endCalibration;
                    }
                  }
                );
                waitingTimerStarted = true;
              }
            } else {
              _distanceCalibration = response;
            }
          }
        );

        /** Check face position */
        BiometricValidation().facePosition(
          dx: _dxPosition ?? 0.0,
          dy: _dyPosition ?? 0.0,
          currentProcess: _distanceCalibration["process"],
          callBack: (response) {
            errorActivator(error: response["error"], text: response["text"]);
          },
        );

        /** Check if user head is centred in euler angle */
        BiometricValidation().headPosition(
          posX: _headEulerPosX ?? 0.0,
          posZ: _headEulerPosZ ?? 0.0,
          posY: _headEulerPosY ?? 0.0,
          callBack: (response) {
            errorActivator(error: response["error"], text: response["text"]);
          }
        );

        /** Check is only one face */
        if(faces.length > 1) {
          errorActivator(error: true, text: "Make sure only you are visible in the view");
        }

        BiometricValidation().eyeOpen(
          right: _rightEyeOpenProbability ?? 0.0,
          left: _leftEyeOpenProbability ?? 0.0,
          callBack: (response) {
            if(response["error"] == true) {
              /** Checking if user keeping eyes closed */
              Future.delayed(const Duration(milliseconds: 500), () {
                if(!(_rightEyeOpenProbability! > 0.85 && _leftEyeOpenProbability! > 0.85)) {
                  errorActivator(error: true, text: response["text"]);
                } else {
                  errorActivator(error: false, text: response["text"]);
                }
              });
            }
          },
        );

        FraudValidation().getDeviation(
          dataSet: eyesMovingDataSet,
          callBack: (double deviation) {
            eyeMovingDeviation = deviation;
          }
        );
        FraudValidation().getDeviation(
            dataSet: headZPosDataSet,
            callBack: (double deviation) {
              headZPosDeviation = deviation;
            }
        );

        // /** Check mobile attack suspect */
        // if(_mobileAttackSuspectConfidence > 0.30 && _mobileAttackSuspectConfidence < 0.65) {
        //   _faceValidationError["attackSuspect"] = true;
        //   errorDelayDeactivation();
        // } else if(_mobileAttackSuspectConfidence <= 0.30) {
        //   if(!_errorIsActive) {
        //     _faceValidationError["attackSuspect"] = false;
        //   }
        // }

        // /** Check poster attack suspect */
        // if(_posterAttackSuspectConfidence > 0.2 && _posterAttackSuspectConfidence < 0.5) {
        //   _faceValidationError["attackSuspect"] = true;
        //   errorDelayDeactivation();
        // } else if(_mobileAttackSuspectConfidence <= 0.2) {
        //   if(!_errorIsActive) {
        //     _faceValidationError["attackSuspect"] = false;
        //   }
        // }

        // /** Check face tracking ID */
        // if(widget.faceTrackingID != _trackingID) {
        //   _faceValidationError["faceTrackingID"] = true;
        // } else {
        //   _faceValidationError["faceTrackingID"] = false;
        // }
      });
    }
    _isBusy = false;
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _imageLabeler.close();
    eyesMovingDataSet.clear();
    headZPosDataSet.clear();
    super.dispose();
  }
}