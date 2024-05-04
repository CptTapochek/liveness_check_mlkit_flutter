import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/main.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/components/back_button.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/components/display_preview.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/components/face_preview_zone.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/components/inform_label.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/components/inform_speaker.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/components/progress_bar.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/camera_view/components/timer_label.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/debug_data_view.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/move_face_on_median_plane.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/real_time_graph.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/utilities.dart';
import 'package:next_vision_flutter_app/src/components/custom_error_widget.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';


class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.onImage,
    required this.customPaint,
    this.initialDirection = CameraLensDirection.back,
    this.debugMode = false,
    this.debugValuesList = const [{"title": "characteristic title", "value": "characteristic value"}],
    required this.distanceCalibration,
    this.error = false,
    this.errorText = "",
    this.graphData = 0.0,
  }) : super(key: key);
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final bool debugMode;
  final bool error;
  final String errorText;
  final List debugValuesList;
  final CustomPaint? customPaint;
  final Map distanceCalibration;
  final double graphData;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _cameraController;
  int _cameraIndex = -1;
  bool _cameraIsInit = false;
  bool graphModeActivated = false;
  XFile? imageFile;
  late InputImage globalInputImage;

  @override
  void initState() {
    Utilities().getPermissions();
    if (cameras.any((element) => element.lensDirection == widget.initialDirection && element.sensorOrientation == 90)) {
      _cameraIndex = cameras.indexOf(
          cameras.firstWhere((element) => element.lensDirection == widget.initialDirection && element.sensorOrientation == 90));
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
    Future.delayed(const Duration(milliseconds: 1500)).then((value) => {
      if(mounted) {
        setState(() => _cameraIsInit = true)
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _liveFeedBody();
  }

  Widget _liveFeedBody() {
    if (_cameraController?.value.isInitialized == false) {
      return const SizedBox();
    } else if (_cameraController == null) {
      return const CustomErrorWidget();
    }

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          DisplayPreview(cameraController: _cameraController),
          FacePreviewZone(error: widget.error, distanceCalibration: widget.distanceCalibration),
          /** This positioned bloc is using for debugging */
          if (widget.debugMode && widget.customPaint != null)
            Positioned(child: widget.customPaint!),
          /** This positioned bloc is using for debugging */
          if (widget.debugMode && !graphModeActivated)
            Positioned(
              width: const AppSize().screenW(),
              bottom: 0,
              child: DebugDataView(debugValuesList: widget.debugValuesList)
            ),
          if(widget.debugMode && graphModeActivated)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom,
              width: const AppSize().screenW(),
              height: const AppSize().flex(100),
              child: RealTimeGraphCustom(data: widget.graphData),
            ),
          if(widget.debugMode)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              child: Switch(
                value: graphModeActivated,
                onChanged: (bool value) {
                  setState(() => graphModeActivated = !graphModeActivated);
                }
              ),
            ),
          /** Back button */
          Positioned(
            top: MediaQuery.of(context).padding.top + const AppSize().flex(10),
            left: const AppSize().flex(5),
            child: const CameraViewBackButton(),
          ),
          /** Speaker */
          Positioned(
            right: const AppSize().flex(5),
            top: MediaQuery.of(context).padding.top + const AppSize().flex(10),
            child: const InformSpeaker()
          ),
          /** Text informing the user */
          Positioned(
            top: MediaQuery.of(context).padding.top + const AppSize().screenW() * 1.2 + const AppSize().flex(40),
            child: InformLabel(
              text: widget.error ? widget.errorText : widget.distanceCalibration["text"] ?? "",
              errorActive: widget.error
            ),
          ),
          /** Progress bar */
          if(widget.distanceCalibration["progressIndicator"] == true)
            Positioned(
              top: MediaQuery.of(context).padding.top + const AppSize().screenW() * 1.2 + const AppSize().flex(110),
              child: ProgressBar(progress: widget.distanceCalibration["progress"], errorActive: widget.error)
            ),
          if(widget.distanceCalibration["phase"] == CurrentPhase.wait)
            Positioned(
              top: MediaQuery.of(context).padding.top + const AppSize().flex(30) + const AppSize().screenW() * 0.5,
              child: TimerLabel(second: widget.distanceCalibration["waitingTime"] ?? 0)
            )
        ],
      )
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    _cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _cameraController?.stopImageStream();
    _cameraController?.dispose();
  }

  Future _processCameraImage(CameraImage image) async {
    final inputImage = Utilities().inputImageFromCameraImage(image, _cameraIndex);
    if (inputImage == null) return;
    globalInputImage = inputImage;
    widget.onImage(inputImage);
  }

  Future<XFile?> takePicture() async {
    if (_cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      final XFile file = await _cameraController!.takePicture();
      return file;
    } on CameraException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if(mounted){
        Utilities().showCameraException(error: e, context: context);
      }
      return null;
    }
  }
}
