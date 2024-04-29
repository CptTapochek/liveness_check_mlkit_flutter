import 'dart:io';
import 'dart:math';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:next_vision_flutter_app/main.dart';
import 'package:next_vision_flutter_app/src/components/custom_error_widget.dart';
import 'package:next_vision_flutter_app/src/constants/buttons.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';
import 'package:next_vision_flutter_app/src/face_authorization/face_authorization.dart';
import 'package:next_vision_flutter_app/src/liveness_check/complete_verification_fail.dart';
import 'package:next_vision_flutter_app/src/liveness_check/components/rotate_look_position_arc.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';


class LivenessCheckCameraView extends StatefulWidget {
  const LivenessCheckCameraView({
    Key? key,
    required this.onImage,
    required this.faceValidation,
    required this.customPaint,
    this.initialDirection = CameraLensDirection.back,
    required this.debugMode,
    required this.disableVerification,
    required this.disableVerificationCallBack,
    this.debugValuesList = const [
      {
        "title": "characteristic title",
        "value": "characteristic value",
      }
    ],
    required this.challenge,
    this.challengeIsComplete = false,
    this.progress = 0.0,
    required this.faceTrackingID,
    this.isTest = false,
    this.completFail = false,
  }) : super(key: key);
  final Map faceValidation;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final bool debugMode;
  final List debugValuesList;
  final CustomPaint? customPaint;
  final Map challenge;
  final bool challengeIsComplete;
  final double progress;
  final int faceTrackingID;
  final bool isTest;
  final bool completFail;
  final bool disableVerification;
  final dynamic disableVerificationCallBack;

  @override
  State<LivenessCheckCameraView> createState() => _LivenessCheckCameraViewState();
}

class _LivenessCheckCameraViewState extends State<LivenessCheckCameraView> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  int _cameraIndex = -1;
  bool _successPositioned = false, _cameraIsInit = false;
  late InputImage globalInputImage;
  late AnimationController controller;
  late Animation animation;
  Color arcColor = Colors.transparent;

  @override
  void initState() {
    Permission.manageExternalStorage.request();
    Permission.storage.request();
    Permission.mediaLibrary.request();
    if (cameras.any((element) => element.lensDirection == widget.initialDirection && element.sensorOrientation == 90)) {
      _cameraIndex = cameras.indexOf(cameras.firstWhere((element) => element.lensDirection == widget.initialDirection));
    } else {
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == widget.initialDirection) {
          _cameraIndex = i;
          break;
        }
      }
    }
    _startLiveFeed();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    animation = ColorTween(begin: const AppColors().danger(15), end: const AppColors().success(17)).animate(controller);
    animation.addListener(() {
      setState(() => arcColor = animation.value);
    });
    controller.forward();

    Future.delayed(const Duration(milliseconds: 1500)).then((value) => {setState(() => _cameraIsInit = true)});
    super.initState();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    _cameraController!.dispose();
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
    _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _cameraController!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    if (widget.progress > 0.4) {
      controller.forward();
    } else {
      controller.reverse();
    }

    String getErrorText() {
      if (widget.faceValidation["distanceTooFar"]) {
        setState(() => _successPositioned = false);
        return "Move closer";
      } else if (widget.faceValidation["distanceTooClose"]) {
        setState(() => _successPositioned = false);
        return "Move further away";
      } else if (widget.faceValidation["position"]) {
        setState(() => _successPositioned = false);
        return "Position your face within the designated area";
      } else if (widget.faceValidation["moreFaces"]) {
        setState(() => _successPositioned = false);
        return "Make sure only you are visible in the photo";
      } else if (widget.faceValidation["attackSuspect"]) {
        setState(() => _successPositioned = false);
        return "Position your face centered in the circle and ensure a clean background";
      } else {
        setState(() => _successPositioned = true);
        return widget.challenge["label"];
      }
    }

    Color getStateColor() {
      if (_successPositioned && !widget.challengeIsComplete) {
        return const AppColors().branding(16);
      } else if (widget.challengeIsComplete) {
        return const AppColors().success(17);
      } else {
        return const AppColors().danger(15);
      }
    }

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(_cameraController!)),
          ),
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              const AppColors().basic(1).withOpacity(0.9),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(bottom: const AppSize().flex(120)),
                    height: const AppSize().screenW() * 0.9,
                    width: const AppSize().screenW() * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width / 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            width: const AppSize().screenW() * 0.9 - 8,
            height: (const AppSize().screenW() * 0.9) - 8 + const AppSize().flex(120),
            child: Container(
              margin: EdgeInsets.only(bottom: const AppSize().flex(120)),
              child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(const AppSize().screenW() / 2),
                  dashPattern: [25, widget.challengeIsComplete ? 0 : 10],
                  color: getStateColor(),
                  strokeWidth: 8,
                  child: const SizedBox()),
            ),
          ),
          /** This positioned bloc is using for debugging */
          if (widget.debugMode && widget.customPaint != null) Positioned(child: widget.customPaint!),
          /** This positioned bloc is using for debugging */
          if (widget.debugMode)
            Positioned(
              width: const AppSize().screenW(),
              bottom: 0,
              child: Container(
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.all(6),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (int idx = 0; idx < widget.debugValuesList.length; idx++)
                          Text(
                            "${widget.debugValuesList[idx]["title"]}: ${widget.debugValuesList[idx]["value"]}",
                            style: const TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  )),
            ),
          if (widget.debugMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + const AppSize().flex(40),
              child: AppButtons().filledSquareButton(
                  function: () => widget.disableVerificationCallBack(!widget.disableVerification),
                  text: "${widget.disableVerification ? "Enable" : "Disable"} verification",
                  width: const AppSize().screenW() * 0.5),
            ),
          if (!widget.challengeIsComplete && _cameraIsInit)
            Positioned(
              width: const AppSize().screenW() * 0.7,
              child: Container(
                margin: EdgeInsets.only(top: const AppSize().flex(300)),
                alignment: Alignment.center,
                child: Text(
                  getErrorText(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: const AppSize().fontFlex(16),
                      fontWeight: FontWeight.w500,
                      color: _successPositioned ? const AppColors().branding(16) : const AppColors().danger(15)),
                ),
              ),
            ),
          if (_cameraIsInit)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.linear,
              width: (widget.challengeIsComplete) ? const AppSize().screenW() * 0.8 : 0,
              child: Container(
                width: const AppSize().flex(160),
                margin: EdgeInsets.only(top: const AppSize().flex(300)),
                alignment: Alignment.center,
                child: AppButtons().filledSquareButton(
                  function: () => Get.to(FaceAuthorization(isTest: widget.isTest, faceTrackingID: widget.faceTrackingID)),
                  text: "CONTINUE",
                  width: const AppSize().screenW() * 0.8,
                  filledColor: const AppColors().success(17),
                  textColor: const AppColors().basic(1),
                  suffix: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const AppColors().basic(1),
                      size: const AppSize().flex(16),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
              left: const AppSize().flex(5),
              child: Container(
                margin: EdgeInsets.only(bottom: const AppSize().flex(400)),
                child: TextButton(
                  onPressed: () => Get.offAll(Home()),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: const AppColors().basic(22),
                    size: const AppSize().flex(28),
                  ),
                ),
              )),
          if (!widget.challengeIsComplete && _successPositioned)
            Positioned(
                width: const AppSize().flex(60),
                left: RotateLookPositionArc().getPosition(widget.challenge["targetPosition"])["left"],
                right: RotateLookPositionArc().getPosition(widget.challenge["targetPosition"])["right"],
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: RotateLookPositionArc().getPosition(widget.challenge["targetPosition"])["bottom"] ??
                        const AppSize().flex(120),
                    top: RotateLookPositionArc().getPosition(widget.challenge["targetPosition"])["top"] ?? 0,
                  ),
                  child: Transform.rotate(
                    angle: (RotateLookPositionArc().getArcVAngle(widget.challenge["targetPosition"]) * 1 * pi) +
                        RotateLookPositionArc().getArcHAngle(widget.challenge["targetPosition"]),
                    child: SvgPicture.asset(
                      "assets/icons/look-position.svg",
                      color: arcColor,
                      width: const AppSize().flex(160),
                    ),
                  ),
                )),
          if (kDebugMode)
            Positioned(
                right: const AppSize().flex(5),
                child: Container(
                  margin: EdgeInsets.only(bottom: const AppSize().flex(400)),
                  child: TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/speaker.svg",
                        width: const AppSize().flex(24),
                      )),
                )),
          if (widget.completFail)
            Positioned(
              width: const AppSize().screenW(),
              height: const AppSize().screenH(),
              child: BlurryContainer(
                  blur: 3,
                  elevation: 0,
                  width: const AppSize().screenW(),
                  height: const AppSize().screenH(),
                  color: const AppColors().branding(21),
                  borderRadius: const BorderRadius.all(Radius.circular(0)),
                  child: Center(child: CompleteVerificationFail(isTest: widget.isTest))),
            )
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
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
    await _cameraController?.dispose();
    _cameraController = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    globalInputImage = inputImage;
    widget.onImage(inputImage);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = cameras[_cameraIndex];
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
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

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
