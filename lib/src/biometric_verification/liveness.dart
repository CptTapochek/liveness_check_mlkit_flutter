import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/screens/camera_view/camera_view.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/fraud_validation.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/move_face_on_median_plane.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/biometric_validation.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/screens/fraud_detected.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/screens/success_check.dart';
import 'package:next_vision_flutter_app/src/constants/app_bar_state.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/painters/face_detector_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';



class Liveness extends StatefulWidget {
  const Liveness({
    Key? key,
    required this.rootWidget
  }) : super(key: key);
  final Widget rootWidget;

  @override
  State<Liveness> createState() => _LivenessState();
}

class _LivenessState extends State<Liveness> {
  BuildContext? widgetContext;
  final _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.3));
  final TurnHeadDirections _lookDirection = MoveFaceOnMedianPlane.turnHeadDirections[Random().nextInt(2)];
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableTracking: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _canProcess = true, _isBusy = false, _transitionDelayStarted = false;
  final bool _debugMode = kDebugMode;
  CustomPaint? _customPaint;
  double? _dxPosition = 0.0, _dyPosition = 0.0, _faceHeight = 0.0, _faceWidth = 0.0;
  double? _rightEyeOpenProbability = 1.0, _leftEyeOpenProbability = 1.0, eyeMovingDeviation = 0.0;
  List<double> eyesMovingDataSet = [], headZPosDataSet = [];
  double? _headEulerPosX = 0.0, _headEulerPosY = 0.0, _headEulerPosZ = 0.0, headZPosDeviation = 0.0;
  int? _upperLipBottomDY = 0, _lowerLipTopDY = 0;
  Map _distanceCalibration = {};
  int? _trackingID;
  bool _errorIsActivated = false;
  bool _existFace = false;
  bool waitingTimerStarted = false;
  String _errorText = "";
  bool fraudDetected = false;   /// This is the variable which respond for instant fraud response
  bool fraudResponse = false;   /// This variable respond for the future fraud response
  List<Map> debugRealTimeData = [], debugFinalData = [];
  List<String> detectedFrauds = [];
  int _countedErrors = 0;

  @override
  void initState() {
    _distanceCalibration = {
      "process": CurrentProcess.longDistance,
      "phase": CurrentPhase.initFaceDistance,
      "text": "",
      "progress": 0.0,
      "progressIndicator": false,
      "waitingTime": MoveFaceOnMedianPlane.waitingTime,
      "lookDirection": _lookDirection
    };
    FraudValidation().sessionTimer(
      callBack: (int value) {
        if(value == 0 && (_distanceCalibration["phase"] == CurrentPhase.calibrateFace || _distanceCalibration["phase"] == CurrentPhase.turnHead)) {
          activateFraudDetection();
          addFraud("timeOut");
        }
      },
    );
    super.initState();
  }

  void addFraud(String fraudTitle) {
    if(!detectedFrauds.contains(fraudTitle)) {
      setState(() => detectedFrauds.add(fraudTitle));
    }
  }

  void activateFraudDetection() async {
    setState(() => fraudDetected = true);
    await Future.delayed(const Duration(milliseconds: 300), () {});
    Navigator.pushAndRemoveUntil(widgetContext!, MaterialPageRoute(
        builder: (context) => FraudDetected(rootWidget: widget.rootWidget, debugData: debugFinalData)
    ), (route) => false);
  }

  Future errorActivator({required bool error, required String text}) async {
    if(_distanceCalibration["phase"] == CurrentPhase.wait && error) {
      activateFraudDetection();
      addFraud("wrongKeepingHeadPosition");
    } else {
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
  }

  void checkValidationBlocks() {
    FraudValidation().eyesMovingDeviationCheck(
      deviation: eyeMovingDeviation ?? 0,
      callBack: (bool error) {
        setState(() => fraudResponse = error);
        if(error) {
          addFraud("eyesMovingDeviation");
        }
      }
    );
    FraudValidation().headMovingDeviationCheck(
      deviation: headZPosDeviation ?? 20.0,
      callBack: (bool error) {
        setState(() => fraudResponse = error);
        if(error) {
          addFraud("headMovingDeviation");
        }
      }
    );
    if(_countedErrors >= FraudValidation.maximalFraudAttempts) {
      setState(() {
        fraudResponse = true;
        addFraud("tooManyFraudAttempts");
      });
    }
  }

  void _transition() {
    if(!_transitionDelayStarted) {
      setState(() => _transitionDelayStarted = true);
      Future.delayed(const Duration(seconds: 1), () {
        if(mounted) {
          setState(() => _distanceCalibration["phase"] = CurrentPhase.calibrateFace);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widgetContext ??= context;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarState().dark,
      body: CameraView(
        onImage: (inputImage) {
          processImage(inputImage);
        },
        rootWidget: widget.rootWidget,
        fraudDetected: fraudDetected,
        graphData: ((_rightEyeOpenProbability ?? 1.0) + (_leftEyeOpenProbability ?? 1.0)) / 2,
        // graphData: _headEulerPosZ ?? 0.0,
        distanceCalibration: _distanceCalibration,
        customPaint: _customPaint,
        initialDirection: CameraLensDirection.front,
        error: _errorIsActivated,
        errorText: _errorText,
        debugMode: _debugMode,
        debugValuesList: debugRealTimeData
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
        _rightEyeOpenProbability = face.rightEyeOpenProbability ?? 1.0;
        _leftEyeOpenProbability = face.leftEyeOpenProbability ?? 1.0;
        ///dataSet = ((rightEye + leftEye) / 2) * 100 -> round to 2 decimals
        eyesMovingDataSet.add(double.parse(((((_rightEyeOpenProbability ?? 1.0) + (_leftEyeOpenProbability ?? 1.0)) / 2) * 100).toStringAsFixed(2)));
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
        _trackingID ??= face.trackingId;
        if(_trackingID != face.trackingId) {
          if(mounted) {
            setState(() {
              fraudResponse = true;
              addFraud("wrongFaceTrackingID");
            });
          }
        }
      }

      for (ImageLabel label in labels) {
        final String text = label.label;
        final double confidence = label.confidence;
        Map params = {};
        // if(confidence > 0.4) {
        //   print("====$text=======++${confidence}");
        // }

        if(text == "Mobile phone") {
          params["mobilePhone"] = confidence;
        } else {
          params.remove("mobilePhone");
        }
        if(text == "Television") {
          params["television"] = confidence;
        } else {
          params.remove("television");
        }
        if(text == "Paper") {
          params["paper"] = confidence;
        } else {
          params.remove("paper");
        }

        if(params.isNotEmpty) {
          FraudValidation().fraudObjectsDetection(
            fraudObj: params,
            callBack: (int errors) {
              _countedErrors += errors;
            }
          );
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
          headPosY: _headEulerPosY ?? 0.0,
          currentPhase: _distanceCalibration["phase"] ?? CurrentPhase.initFaceDistance,
          currentProcess: _distanceCalibration["process"] ?? CurrentProcess.longDistance,
          errorIsActive: _errorIsActivated,
          lookDirection: _lookDirection,
          callBack: (response) {
            if(_distanceCalibration["phase"] == CurrentPhase.wait) {
              _distanceCalibration["progressIndicator"] = false;
              if(!waitingTimerStarted) {
                MoveFaceOnMedianPlane().countDownWaitingProcess(
                  callBack: (int second) {
                    _distanceCalibration["waitingTime"] = second;
                    if(second == MoveFaceOnMedianPlane.waitingTime) {
                      _distanceCalibration["phase"] = CurrentPhase.endCalibration;
                    }
                    checkValidationBlocks();
                    /** Final response */
                    if(second == 0 && !fraudResponse) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SuccessCheck(
                        rootWidget: widget.rootWidget,
                        debugData: debugFinalData,
                      )), (route) => false);
                    } else if(second == 0 && fraudResponse) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) => FraudDetected(rootWidget: widget.rootWidget, debugData: debugFinalData)
                      ), (route) => false);
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
        if(_distanceCalibration["phase"] != CurrentPhase.turnHead && _distanceCalibration["phase"] != CurrentPhase.transition) {
          BiometricValidation().facePosition(
            dx: _dxPosition ?? 0.0,
            dy: _dyPosition ?? 0.0,
            currentProcess: _distanceCalibration["process"],
            callBack: (response) {
              errorActivator(error: response["error"], text: response["text"]);
            },
          );
        }

        /** Check if user head is centred in euler angle */
        BiometricValidation().headPosition(
          posX: _headEulerPosX ?? 0.0,
          posZ: _headEulerPosZ ?? 0.0,
          posY: _headEulerPosY ?? 0.0,
          turnHeadPhase: _distanceCalibration["phase"] == CurrentPhase.turnHead || _distanceCalibration["phase"] == CurrentPhase.transition,
          callBack: (response) {
            errorActivator(error: response["error"], text: response["text"]);
          },
        );

        /** Check is only one face */
        if(faces.length > 1) {
          errorActivator(error: true, text: "Make sure only you are visible in the view");
        }

        if(_distanceCalibration["phase"] == CurrentPhase.calibrateFace) {
          BiometricValidation().eyeOpen(
            right: _rightEyeOpenProbability ?? 1.0,
            left: _leftEyeOpenProbability ?? 1.0,
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
        }
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

        if(_distanceCalibration["phase"] == CurrentPhase.transition) {
          _transition();
        }

        debugRealTimeData = [
          {"title":"Face tracking ID", "value": _trackingID ?? 0},
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
          {"title":"Exist Faces", "value": _existFace},
          {"title":"Eye moving deviation", "value": eyeMovingDeviation?.toStringAsFixed(2)},
          {"title":"Head z pos deviation", "value": headZPosDeviation?.toStringAsFixed(2)},
          {"title":"Fraud attempts detected", "value": _countedErrors},
          {"title":"Fraud attempts detected", "value": _countedErrors},
        ];
        debugFinalData = [
          {"title":"Face tracking ID", "value": _trackingID ?? 0},
          {"title":"Eye moving deviation", "value": eyeMovingDeviation?.toStringAsFixed(2)},
          {"title":"Head z pos deviation", "value": headZPosDeviation?.toStringAsFixed(2)},
          {"title":"Fraud attempts detected", "value": _countedErrors},
          {"title":"List of detected frauds", "value": detectedFrauds.toString()},
        ];
      });
    }
    _isBusy = false;
  }

  @override
  void dispose() {
    _canProcess = false;
    fraudDetected = false;
    _faceDetector.close();
    _imageLabeler.close();
    eyesMovingDataSet.clear();
    headZPosDataSet.clear();
    super.dispose();
  }
}
