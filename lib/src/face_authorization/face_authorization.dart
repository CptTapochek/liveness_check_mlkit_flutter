import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/constants/app_bar_state.dart';
import 'package:next_vision_flutter_app/src/face_authorization/components/camera_view.dart';
import 'package:next_vision_flutter_app/src/face_authorization/components/painters/face_detector_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';



class FaceAuthorization extends StatefulWidget {
  const FaceAuthorization({
    Key? key,
    this.faceTrackingID = 0,
    this.isTest = false
  }) : super(key: key);
  final int faceTrackingID;
  final bool isTest;

  @override
  State<FaceAuthorization> createState() => _FaceAuthorizationState();
}

class _FaceAuthorizationState extends State<FaceAuthorization> {
  final _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.2));
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  final bool _debugMode = kDebugMode;
  CustomPaint? _customPaint;
  double? _dxPosition = 0.0, _dyPosition = 0.0, _faceHeight = 0.0, _faceWidth = 0.0;
  double? _smileProbability = 0.0, _rightEyeOpenProbability = 0.0, _leftEyeOpenProbability = 0.0;
  double? _headEulerPosX = 0.0, _headEulerPosY = 0.0, _headEulerPosZ = 0.0;
  double? _glassesProbability = 0.0, _otherObjectsProbability = 0.0;
  int? _upperLipBottomDY = 0, _lowerLipTopDY = 0;
  Map _faceValidationError = {};
  int? _trackingID = 0;
  bool _errorIsActive = false;
  double _mobileAttackSuspectConfidence = 0.0, _posterAttackSuspectConfidence = 0.0;
  bool _completFail = false;
  int _countErrors = 0;

  @override
  void initState() {
    super.initState();
    _faceValidationError = {
      "distanceTooFar": false,
      "distanceTooClose": false,
      "position": false,
      "smile": false,
      "eyesOpen": false,
      "eulerAngle": false,
      "moreFaces": false,
      "glasses": false,
      "monthOpened": false,
      "faceNotExist": false,
      "faceTrackingID": false,
      "attackSuspect": false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarState().dark,
      body: CameraAuthorizationView(
        isTest: widget.isTest,
        onImage: (inputImage) {
          processImage(inputImage);
        },
        customPaint: _customPaint,
        faceValidation: _faceValidationError,
        initialDirection: CameraLensDirection.front,
        debugMode: _debugMode,
        completFail: _completFail,
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
          {"title":"Glasses probability", "value": _glassesProbability},
          {"title":"Smiling probability", "value": _smileProbability},
          {"title":"Month open value", "value": (_lowerLipTopDY! - _upperLipBottomDY!)},
          {"title":"Attack suspect probability", "value": _mobileAttackSuspectConfidence},
          {"title":"Percentage of background issues", "value": _mobileAttackSuspectConfidence},
          {"title":"Exist Faces", "value": !_faceValidationError["faceNotExist"]},
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
        setState(() => _faceValidationError["faceNotExist"] = false);
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

        /* Glasses verification */
        if(text == "Glasses" || text == "Sunglasses" || text == "Goggles" || text == "Helmet") {
          switch(text){
            case "Glasses":
              if(confidence > _glassesProbability!) {
                _glassesProbability = confidence;
              }
              break;
            case "Sunglasses":
              if(confidence > _glassesProbability!) {
                _glassesProbability = confidence;
              }
              break;
            case "Goggles":
              if(confidence > _glassesProbability!) {
                _glassesProbability = confidence;
              }
              break;
            case "Helmet":
              if(confidence > _glassesProbability!) {
                _glassesProbability = confidence;
              }
              break;
          }
        } else if(text != "Glasses" && text != "Sunglasses" && text != "Goggles" && text != "Helmet") {
          Future.delayed(const Duration(milliseconds: 100)).then((value) => {
           _glassesProbability = 0.0
          });
        }

        if(text == "Mobile phone") {
          _mobileAttackSuspectConfidence = confidence;
          _countErrors++;
        } else {
          _mobileAttackSuspectConfidence = 0.1;
        }
        if(text == "Poster") {
          _posterAttackSuspectConfidence = confidence;
          _countErrors++;
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
      await Future.delayed(const Duration(milliseconds: 1400), () {
        setState(() => _errorIsActive = false);
      });
    }

    if(mounted && faces.isNotEmpty) {
      setState(() {
        /** Check distance between face and camera */
        if((_faceHeight! >= 320 && _faceHeight! <= 470) && (_faceWidth! >= 320 && _faceWidth! <= 470)){
          /* Success distance */
          if(!_errorIsActive) {
            _faceValidationError["distanceTooFar"] = false;
            _faceValidationError["distanceTooClose"] = false;
          }
        } else if(_faceHeight! < 320 && _faceWidth! < 320) {
          /* Too far */
          _faceValidationError["distanceTooFar"] = true;
          errorDelayDeactivation();
        } else if(_faceHeight! > 470 && _faceWidth! > 470) {
          /* Too close */
          _faceValidationError["distanceTooClose"] = true;
          errorDelayDeactivation();
        }

        /** Check face position */
        if((_dxPosition! >= 280 && _dxPosition! <= 420) && (_dyPosition! >= 460 && _dyPosition! <= 600)){
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
          _faceValidationError["eyesOpen"] = false;
          _faceValidationError["smile"] = false;
          _faceValidationError["eulerAngle"] = false;
          _faceValidationError["position"] = false;
          _faceValidationError["distanceTooFar"] = false;
          _faceValidationError["distanceTooClose"] = false;
          errorDelayDeactivation();
        }

        /** Check if eyes are open */
        if((_rightEyeOpenProbability! <= 0.7) || (_leftEyeOpenProbability! <= 0.7)) {
          _faceValidationError["eyesOpen"] = true;
          errorDelayDeactivation();
        } else {
          if(!_errorIsActive) {
            _faceValidationError["eyesOpen"] = false;
          }
        }

        /** Check if the user smile */
        if(_smileProbability! >= 0.2) {
          _faceValidationError["smile"] = true;
          errorDelayDeactivation();
        } else {
          if(!_errorIsActive) {
            _faceValidationError["smile"] = false;
          }
        }

        /** Check if user head is centred in euler angle */
        if((_headEulerPosX! >= -12 && _headEulerPosX! <= 16) && (_headEulerPosZ! >= -7 && _headEulerPosZ! <= 7) && (_headEulerPosY! >= -10 && _headEulerPosY! <= 10)) {
          /* Success position */
          if(!_errorIsActive) {
            _faceValidationError["eulerAngle"] = false;
          }
        } else {
          /* Error position */
          _faceValidationError["eulerAngle"] = true;
          errorDelayDeactivation();
        }

        /** Check if don't wear glasses */
        if(_glassesProbability! >= 0.82){
          _faceValidationError["glasses"] = true;
          errorDelayDeactivation();
        } else {
          if(!_errorIsActive) {
            _faceValidationError["glasses"] = false;
          }
        }

        /** Check if month is opened */
        if((_lowerLipTopDY! - _upperLipBottomDY!) >= 5) {
          _faceValidationError["monthOpened"] = true;
          errorDelayDeactivation();
        } else {
          if(!_errorIsActive) {
            _faceValidationError["monthOpened"] = false;
          }
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
        if(_posterAttackSuspectConfidence > 0.2 && _posterAttackSuspectConfidence < 0.5) {
          _faceValidationError["attackSuspect"] = true;
          errorDelayDeactivation();
        } else if(_mobileAttackSuspectConfidence <= 0.2) {
          if(!_errorIsActive) {
            _faceValidationError["attackSuspect"] = false;
          }
        } else if(_posterAttackSuspectConfidence >= 0.5) {
          _completFail = true;
        }

        // /** Suspend session */
        // if(_countErrors >= 20 && !_completFail) {
        //   setState(() => _completFail = true);
        // }

        /** Check face tracking ID */
        if(widget.faceTrackingID != _trackingID) {
          _faceValidationError["faceTrackingID"] = true;
        } else {
          _faceValidationError["faceTrackingID"] = false;
        }
      });
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
//
