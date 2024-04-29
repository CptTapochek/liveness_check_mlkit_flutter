import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:next_vision_flutter_app/src/constants/app_bar_state.dart';
import 'package:next_vision_flutter_app/src/controllers/face_biometrics_controller.dart';
import 'package:next_vision_flutter_app/src/liveness_check/components/liveness_check_camera_view.dart';
import 'package:next_vision_flutter_app/src/liveness_check/components/painters/face_detector_painter.dart';
import 'package:next_vision_flutter_app/src/liveness_check/components/sets_of_challenges.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';


class LivenessCheck extends StatefulWidget {
  const LivenessCheck({
    Key? key,
    this.isTest = false
  }) : super(key: key);
  final bool isTest;

  @override
  State<LivenessCheck> createState() => _LivenessCheckState();
}

class _LivenessCheckState extends State<LivenessCheck> {
  final _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.3));
  FaceBiometricsController faceBiometricsController = Get.put(FaceBiometricsController(), permanent: true);
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _canProcess = true, _isBusy = false, _disableLivenessVerification = false;
  final bool _debugMode = kDebugMode;
  CustomPaint? _customPaint;
  double? _dxPosition = 0.0, _dyPosition = 0.0, _faceHeight = 0.0, _faceWidth = 0.0;
  double? _smileProbability = 0.0, _rightEyeOpenProbability = 0.0, _leftEyeOpenProbability = 0.0;
  double? _headEulerPosX = 0.0, _headEulerPosY = 0.0, _headEulerPosZ = 0.0;
  Map _faceValidationError = {};
  int _trackingID = 0;
  int firstChallengeIndex = 0, secondChallengeIndex = 0, thirdChallengeIndex = 0;
  int? _upperLipBottomDY = 0, _lowerLipTopDY = 0;
  Map challenge = {};
  bool challengeIsComplete = false, firstChallengeIsComplete = false, secondChallengeIsComplete = false;
  bool _errorIsActive = false;
  double _progress = 0.0;
  double _mobileAttackSuspectConfidence = 0.0, _posterAttackSuspectConfidence = 0.0;
  bool _completFail = false;
  int _countErrors = 0;


  @override
  void initState() {
    super.initState();
    challengeIsComplete = false;
    firstChallengeIndex = Random().nextInt(2);
    secondChallengeIndex = Random().nextInt(2);
    thirdChallengeIndex = Random().nextInt(4);
    challenge = setOfLeftRightChallenges[firstChallengeIndex];
    _faceValidationError = {
      "distanceTooFar": false,
      "distanceTooClose": false,
      "position": false,
      "moreFaces": false,
      "attackSuspect": false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarState().dark,
      body: LivenessCheckCameraView(
        isTest: widget.isTest,
        onImage: (inputImage) => processImage(inputImage),
        customPaint: _customPaint,
        faceValidation: _faceValidationError,
        initialDirection: CameraLensDirection.front,
        debugMode: _debugMode,
        challengeIsComplete: challengeIsComplete,
        progress: _progress,
        completFail: _completFail,
        disableVerification: _disableLivenessVerification,
        debugValuesList: [
          {"title":"Face tracking ID", "value": _trackingID},
          {"title":"Position DX", "value": _dxPosition},
          {"title":"Position DY", "value": _dyPosition},
          {"title":"Face height", "value": _faceHeight},
          {"title":"Face width", "value": _faceWidth},
          {"title":"Open left eye probability", "value": _leftEyeOpenProbability},
          {"title":"Open right eye probability", "value": _rightEyeOpenProbability},
          {"title":"Head Euler Position X", "value": _headEulerPosX},
          {"title":"Head Euler Position Y", "value": _headEulerPosY},
          {"title":"Head Euler Position Z", "value": _headEulerPosZ},
          {"title":"Smiling probability", "value": _smileProbability},
          {"title":"Attack suspect probability", "value": _mobileAttackSuspectConfidence},
          {"title":"Month open value", "value": (_lowerLipTopDY! - _upperLipBottomDY!)},
          {"title":"Exist Faces", "value": _faceValidationError["faceNotExist"]},
        ],
        challenge: challenge,
        faceTrackingID: _trackingID,
        disableVerificationCallBack: (bool disabled) {
          _disableLivenessVerification = disabled;
        },
      ),
    );
  }


  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final faces = await _faceDetector.processImage(inputImage);
    final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null && faces.isNotEmpty) {
      if(_debugMode) {
        final painter = FaceDetectorPainter(faces, inputImage.metadata!.size, inputImage.metadata!.rotation);
        _customPaint = CustomPaint(painter: painter);
      }
      Future.delayed(const Duration(milliseconds: 600), () {
        if(mounted) {
          setState(() => _faceValidationError["faceNotExist"] = false);
        }
      });
      for (final Face face in faces) {
        _dxPosition = face.boundingBox.center.dx;
        _dyPosition = face.boundingBox.center.dy;
        _faceHeight = face.boundingBox.height;
        _faceWidth = face.boundingBox.width;
        _smileProbability = face.smilingProbability ?? 0;
        _rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0;
        _leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0;
        _headEulerPosX = face.headEulerAngleX ?? 0;
        _headEulerPosY = face.headEulerAngleY ?? 0;
        _headEulerPosZ = face.headEulerAngleZ ?? 0;
        face.contours.values.forEach((element) {
          if(element != null) {
            if(element.type == FaceContourType.upperLipBottom) {
              _upperLipBottomDY = element.points[5].y;
            } else if(element.type == FaceContourType.lowerLipTop) {
              _lowerLipTopDY = element.points[5].y;
            }
          }
        });
        _trackingID = face.trackingId ?? 0;
      }

      for (ImageLabel label in labels) {
        final String text = label.label;
        final int index = label.index;
        final double confidence = label.confidence;
        // print("---text: $text\n---index: $index \n---confidence: $confidence");
        if(text == "Mobile phone") {
          _countErrors++;
          _mobileAttackSuspectConfidence = confidence;
        } else {
          _mobileAttackSuspectConfidence = 0.1;
        }
        if(text == "Poster") {
          _countErrors++;
          _posterAttackSuspectConfidence = confidence;
        } else {
          _posterAttackSuspectConfidence = 0.1;
        }
        if(text == "Paper" && confidence >= 0.35) {
          _countErrors++;
        }
      }
    } else if(faces.isEmpty) {
      setState(() => _faceValidationError["faceNotExist"] = true);
    }

    Future errorDelayDeactivation() async {
      setState(() => _errorIsActive = true);
      await Future.delayed(const Duration(milliseconds: 1000), () {
        if(mounted) {
          setState(() => _errorIsActive = false);
        }
      });
    }


    if(mounted && faces.isNotEmpty && !_disableLivenessVerification) {
      setState(() {
        /** Check distance between face and camera */
        if((_faceHeight! >= 300 && _faceHeight! <= 450) && (_faceWidth! >= 300 && _faceWidth! <= 450)){
          /* Success distance */
          if(!_errorIsActive) {
            _faceValidationError["distanceTooFar"] = false;
            _faceValidationError["distanceTooClose"] = false;
          }
        } else if(_faceHeight! < 300 && _faceWidth! < 300) {
          /* Too far */
          _faceValidationError["distanceTooFar"] = true;
          errorDelayDeactivation();
        } else if(_faceHeight! > 450 && _faceWidth! > 450) {
          /* Too close */
          _faceValidationError["distanceTooClose"] = true;
          errorDelayDeactivation();
        }

        /** Check face position */
        if((_dxPosition! >= 220 && _dxPosition! <= 480) && (_dyPosition! >= 420 && _dyPosition! <= 650)){
          /* Success position */
          if(!_errorIsActive) {
            _faceValidationError["position"] = false;
          }
        } else {
          /* Error position */
          _faceValidationError["position"] = true;
          errorDelayDeactivation();
        }

        /** Check is only one face */
        if(faces.length == 1) {
          if(!_errorIsActive) {
            _faceValidationError["moreFaces"] = false;
          }
        } else {
          _faceValidationError["moreFaces"] = true;
          _faceValidationError["position"] = false;
          _faceValidationError["distanceTooFar"] = false;
          _faceValidationError["distanceTooClose"] = false;
          errorDelayDeactivation();
        }

        /** Check mobile attack suspect */
        if(_mobileAttackSuspectConfidence > 0.30 && _mobileAttackSuspectConfidence < 0.65) {
          _faceValidationError["attackSuspect"] = true;
          errorDelayDeactivation();
        } else if(_mobileAttackSuspectConfidence <= 0.30) {
          if(!_errorIsActive) {
            _faceValidationError["attackSuspect"] = false;
          }
        } else if(_mobileAttackSuspectConfidence >= 0.65) {
          _completFail = true;
        }

        /** Check poster attack suspect */
        if(_posterAttackSuspectConfidence > 0.25 && _posterAttackSuspectConfidence < 0.55) {
          _faceValidationError["attackSuspect"] = true;
          errorDelayDeactivation();
        } else if(_mobileAttackSuspectConfidence <= 0.25) {
          if(!_errorIsActive) {
            _faceValidationError["attackSuspect"] = false;
          }
        } else if(_posterAttackSuspectConfidence >= 0.55) {
          _completFail = true;
        }

        /** Challenge test */
        if(!_errorIsActive && !challengeIsComplete && !firstChallengeIsComplete) {
          Future.delayed(const Duration(seconds: 10), () {
            if(mounted) {
              setState(() {
                if(!firstChallengeIsComplete) {
                  _completFail = true;
                }
              });
            }
          });
          switch(challenge["targetPosition"]) {
            case PositionType.left:
              if(Platform.isAndroid ? (challenge["maxEulerPosY"] < _headEulerPosY) : (challenge["maxEulerPosY"] > _headEulerPosY) && challenge["maxEulerPosX"] > _headEulerPosX && challenge["minEulerPosX"] < _headEulerPosX) {
                setState(() {
                  firstChallengeIsComplete = true;
                  challenge = setOfUpDownChallenges[secondChallengeIndex];
                  _progress = 0;
                });
              } else {
                setState(() => firstChallengeIsComplete = false);
                if(Platform.isAndroid ? _headEulerPosY! >= challenge["minEulerPosY"] : _headEulerPosY! <= challenge["minEulerPosY"]) {
                  _progress = _headEulerPosY! / (challenge["maxEulerPosY"] - challenge["minEulerPosY"]);
                } else {
                  _progress = 0;
                }
              }
              break;
            case PositionType.right:
              if(Platform.isAndroid ? (challenge["maxEulerPosY"] > _headEulerPosY) : (challenge["maxEulerPosY"] < _headEulerPosY) && challenge["maxEulerPosX"] > _headEulerPosX && challenge["minEulerPosX"] < _headEulerPosX) {
                setState(() {
                  firstChallengeIsComplete = true;
                  challenge = setOfUpDownChallenges[secondChallengeIndex];
                });
              } else {
                setState(() => firstChallengeIsComplete = false);
                if(Platform.isAndroid ? _headEulerPosY! <= challenge["minEulerPosY"] : _headEulerPosY! >= challenge["minEulerPosY"]) {
                  _progress = _headEulerPosY! / (challenge["maxEulerPosY"] - challenge["minEulerPosY"]);
                } else {
                  _progress = 0;
                }
              }
              break;
          }
        }

        if(!_errorIsActive && !secondChallengeIsComplete && firstChallengeIsComplete) {
          Future.delayed(const Duration(seconds: 10), () {
            setState(() {
              if(!secondChallengeIsComplete) {
                _completFail = true;
              }
            });
          });
          switch(challenge["targetPosition"]) {
            case PositionType.up:
              if(challenge["maxEulerPosX"] < _headEulerPosX && challenge["maxEulerPosY"] > _headEulerPosY && challenge["minEulerPosY"] < _headEulerPosY) {
                setState(() {
                  secondChallengeIsComplete = true;
                  challenge = setOfCornersChallenges[thirdChallengeIndex];
                  _progress = 0;
                });
              } else {
                setState(() => secondChallengeIsComplete = false);
                if(_headEulerPosX! >= challenge["minEulerPosX"]) {
                  _progress = _headEulerPosX! / (challenge["maxEulerPosX"] - challenge["minEulerPosX"]);
                } else {
                  _progress = 0;
                }
              }
              break;
            case PositionType.down:
              if(challenge["maxEulerPosX"] > _headEulerPosX && challenge["maxEulerPosY"] > _headEulerPosY && challenge["minEulerPosY"] < _headEulerPosY) {
                setState(() {
                  secondChallengeIsComplete = true;
                  challenge = setOfCornersChallenges[thirdChallengeIndex];
                  _progress = 0;
                });
              } else {
                setState(() => secondChallengeIsComplete = false);
                if(-_headEulerPosX! >= challenge["minEulerPosX"]) {
                  _progress = _headEulerPosX! / (challenge["maxEulerPosX"] - challenge["minEulerPosX"]);
                } else {
                  _progress = 0;
                }
              }
              break;
          }
        }

        if(!_errorIsActive && !challengeIsComplete && secondChallengeIsComplete) {
          Future.delayed(const Duration(seconds: 10), () {
            setState(() {
              if(!challengeIsComplete) {
                _completFail = true;
              }
            });
          });
          if (kDebugMode) {
            print("=====Counted error=====$_countErrors");
          }
          switch(challenge["targetPosition"]) {
            case PositionType.topRight:
              if(challenge["maxEulerPosX"] < _headEulerPosX && (Platform.isAndroid ? challenge["maxEulerPosY"] > _headEulerPosY : challenge["maxEulerPosY"] < _headEulerPosY)) {
                setState(() {
                  if(_countErrors <= 6) {
                    challengeIsComplete = true;
                  } else {
                    _completFail = true;
                  }
                });
              } else {
                setState(() => challengeIsComplete = false);
                if(_headEulerPosX! >= challenge["minEulerPosX"] && (Platform.isAndroid ? _headEulerPosY! <= challenge["minEulerPosY"] : _headEulerPosY! >= challenge["minEulerPosY"])) {
                  _progress = (_headEulerPosX! + _headEulerPosY!.abs()) / (challenge["maxEulerPosX"] + challenge["maxEulerPosY"].abs());
                } else {
                  _progress = 0;
                }
              }
              break;
            case PositionType.topLeft:
              if(challenge["maxEulerPosX"] < _headEulerPosX && (Platform.isAndroid ? challenge["maxEulerPosY"] < _headEulerPosY : challenge["maxEulerPosY"] > _headEulerPosY)) {
                setState(() {
                  if(_countErrors <= 6) {
                    challengeIsComplete = true;
                  } else {
                    _completFail = true;
                  }
                });
              } else {
                setState(() => challengeIsComplete = false);
                if(_headEulerPosX! >= challenge["minEulerPosX"] && (Platform.isAndroid ? _headEulerPosY! >= challenge["minEulerPosY"] : _headEulerPosY! <= challenge["minEulerPosY"])) {
                  _progress = (_headEulerPosX! + _headEulerPosY!.abs()) / (challenge["maxEulerPosX"] + challenge["maxEulerPosY"].abs());
                } else {
                  _progress = 0;
                }
              }
              break;
            case PositionType.bottomRight:
              if(challenge["maxEulerPosX"] > _headEulerPosX && (Platform.isAndroid ? challenge["maxEulerPosY"] > _headEulerPosY : challenge["maxEulerPosY"] < _headEulerPosY)) {
                setState(() {
                  if(_countErrors <= 6) {
                    challengeIsComplete = true;
                  } else {
                    _completFail = true;
                  }
                });
              } else {
                setState(() => challengeIsComplete = false);
                if(_headEulerPosX! <= challenge["minEulerPosX"] && (Platform.isAndroid ? _headEulerPosY! <= challenge["minEulerPosY"] : _headEulerPosY! >= challenge["minEulerPosY"])) {
                  _progress = (_headEulerPosX!.abs() + _headEulerPosY!.abs()) / (challenge["maxEulerPosX"].abs() + challenge["maxEulerPosY"].abs());
                } else {
                  _progress = 0;
                }
              }
              break;
            case PositionType.bottomLeft:
              if(challenge["maxEulerPosX"] > _headEulerPosX && (Platform.isAndroid ? challenge["maxEulerPosY"] < _headEulerPosY : challenge["maxEulerPosY"] > _headEulerPosY)) {
                setState(() {
                  if(_countErrors <= 6) {
                    challengeIsComplete = true;
                  } else {
                    _completFail = true;
                  }
                });
              } else {
                setState(() => challengeIsComplete = false);
                if(_headEulerPosX! <= challenge["minEulerPosX"] && (Platform.isAndroid ? _headEulerPosY! >= challenge["minEulerPosY"] : _headEulerPosY! <= challenge["minEulerPosY"])) {
                  _progress = (_headEulerPosX!.abs() + _headEulerPosY!.abs()) / (challenge["maxEulerPosX"].abs() + challenge["maxEulerPosY"].abs());
                } else {
                  _progress = 0;
                }
              }
              break;
          }
        }
      });
    } else if(_disableLivenessVerification) {
      setState(() => challengeIsComplete = true);
    }
    _isBusy = false;
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _imageLabeler.close();
    super.dispose();
  }
}
