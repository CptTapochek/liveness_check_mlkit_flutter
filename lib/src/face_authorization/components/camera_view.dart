import 'dart:io';
import 'dart:math';
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
import 'package:next_vision_flutter_app/src/controllers/face_biometrics_controller.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';


class CameraAuthorizationView extends StatefulWidget {
  const CameraAuthorizationView({
    Key? key,
    required this.onImage,
    required this.faceValidation,
    required this.customPaint,
    this.initialDirection = CameraLensDirection.back,
    this.debugMode = false,
    this.debugValuesList = const [
      {
        "title": "characteristic title",
        "value": "characteristic value",
      }
    ],
    this.isTest = false,
    this.completFail = false,
  }) : super(key: key);
  final Map faceValidation;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final bool debugMode;
  final List debugValuesList;
  final CustomPaint? customPaint;
  final bool completFail;
  final bool isTest;

  @override
  State<CameraAuthorizationView> createState() => _CameraAuthorizationViewState();
}

class _CameraAuthorizationViewState extends State<CameraAuthorizationView> {
  CameraController? _cameraController;
  int _cameraIndex = -1;
  bool _successPositioned = false, _photoIsTaken = false, _cameraIsInit = false;
  XFile? imageFile;
  FaceBiometricsController faceBiometricsController = Get.put(FaceBiometricsController());
  late InputImage globalInputImage;

  @override
  void initState() {
    Permission.manageExternalStorage.request();
    Permission.storage.request();
    Permission.mediaLibrary.request();
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
    Future.delayed(const Duration(milliseconds: 1500)).then((value) => {setState(() => _cameraIsInit = true)});
    faceBiometricsController.error.value = false;
    faceBiometricsController.loading.value = false;
    faceBiometricsController.imageIsTaken.value = false;
    faceBiometricsController.image.value = "";
    faceBiometricsController.existErrorText.value = "";
    faceBiometricsController.finalImageExistError.value = false;
    faceBiometricsController.errorMessage.value = "";
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

    String getErrorText() {
      if (widget.faceValidation["distanceTooFar"]) {
        _successPositioned = false;
        return "Move closer";
      } else if (widget.faceValidation["distanceTooClose"]) {
        _successPositioned = false;
        return "Move further away";
      } else if (widget.faceValidation["position"]) {
        _successPositioned = false;
        return "Position your face within the designated area";
      } else if (widget.faceValidation["smile"]) {
        _successPositioned = false;
        return "Don't smile please";
      } else if (widget.faceValidation["eulerAngle"]) {
        _successPositioned = false;
        return "Keep your head straight and look directly into the camera";
      } else if (widget.faceValidation["eyesOpen"]) {
        _successPositioned = false;
        return "Open your eyes please";
      } else if (widget.faceValidation["moreFaces"]) {
        _successPositioned = false;
        return "Make sure only you are visible in the photo";
      } else if (widget.faceValidation["glasses"]) {
        _successPositioned = false;
        return "Remove head coverings and glasses";
      } else if (widget.faceValidation["monthOpened"]) {
        _successPositioned = false;
        return "Close your month please";
      } else if (widget.faceValidation["faceNotExist"]) {
        _successPositioned = false;
        return "Position your face within the designated area";
      } else if (widget.faceValidation["faceTrackingID"]) {
        _successPositioned = false;
        return "Face does not match, please try again";
      } else if (widget.faceValidation["attackSuspect"]) {
        _successPositioned = false;
        return "Position your face centered in the circle and ensure a clean background";
      } else {
        _successPositioned = true;
        return "";
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
              child: Center(
                  child: (_photoIsTaken && imageFile != null)
                      ? Transform(
                    transform: Matrix4.rotationY(-2 * pi / 2),
                    alignment: Alignment.center,
                    child: Image.file(File(imageFile!.path)),
                  )
                      : CameraPreview(_cameraController!)),
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
                    dashPattern: [25, _photoIsTaken ? 0 : 10],
                    color: (_photoIsTaken && _successPositioned)
                        ? const AppColors().branding(16)
                        : (_successPositioned && _cameraIsInit
                        ? const AppColors().branding(16)
                        : const AppColors().danger(15)),
                    strokeWidth: 8,
                    child: const SizedBox()),
              ),
            ),
            /** This positioned bloc is using for debugging */
            if (widget.debugMode && widget.customPaint != null) Positioned(child: widget.customPaint!),
            /** This positioned bloc is using for debugging */
            if (widget.debugMode && widget.isTest)
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
            // if(widget.debugMode)
            //   Positioned(
            //     top: MediaQuery.of(context).padding.top + 20,
            //     child: AppButtons().filledSquareButton(
            //       function: () => faceBiometricsController.fakeBiometricCheck(),
            //       text: "Fake bind check",
            //       filledColor: const AppColors().danger(15),
            //       textColor: const AppColors().basic(1),
            //       width: const AppSize().screenW() * 0.6,
            //     )
            //   ),
            if (!_photoIsTaken)
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
                        fontSize: const AppSize().fontFlex(16), fontWeight: FontWeight.w500, color: const AppColors().danger(15)),
                  ),
                ),
              )
            else if (_photoIsTaken && faceBiometricsController.finalImageExistError.isTrue)
              Positioned(
                width: const AppSize().screenW() * 0.7,
                child: Container(
                  margin: EdgeInsets.only(top: const AppSize().flex(240)),
                  alignment: Alignment.center,
                  child: Text(
                    faceBiometricsController.existErrorText.value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: const AppSize().fontFlex(16), fontWeight: FontWeight.w500, color: const AppColors().danger(15)),
                  ),
                ),
              ),
            if (!_photoIsTaken && _cameraIsInit)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
                width: (_successPositioned && !_photoIsTaken && _cameraIsInit) ? const AppSize().screenW() * 0.8 : 0,
                child: Container(
                  width: const AppSize().flex(160),
                  margin: EdgeInsets.only(top: const AppSize().flex(300)),
                  alignment: Alignment.center,
                  child: AppButtons().filledSquareButton(
                    function: () {
                      if (_successPositioned && _cameraIsInit) {
                        _cameraController != null && _cameraController!.value.isInitialized
                            ? onTakePictureButtonPressed()
                            : null;
                        setState(() => _successPositioned = false);
                      }
                    },
                    text: "TAKE PHOTO",
                    width: const AppSize().screenW() * 0.8,
                    filledColor: const AppColors().branding(16),
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
              )
            else if (_photoIsTaken)
              Positioned(
                  width: const AppSize().screenW() * 0.9,
                  child: Container(
                    margin: EdgeInsets.only(top: const AppSize().flex(320)),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        if (faceBiometricsController.finalImageExistError.isFalse && faceBiometricsController.loading.isFalse)
                          AppButtons().filledSquareButton(
                            function: () {
                              // if (widget.isTest) {
                              //   Get.offAll(SuccessBinding(
                              //     isTest: widget.isTest,
                              //     percentOfMatch: '99.924442255',
                              //     imagePath: imageFile!.path,
                              //     debugValuesList: widget.debugValuesList,
                              //   ));
                              // } else {
                              //   if (imageFile != null && faceBiometricsController.finalImageExistError.isFalse) {
                              //     faceBiometricsController.biometricCheck(imageFile!.path);
                              //     if (faceBiometricsController.error.isTrue) {
                              //       faceBiometricsController.error.value = false;
                              //       _cameraController!.startImageStream(_processCameraImage);
                              //       setState(() {
                              //         _successPositioned = false;
                              //         _photoIsTaken = false;
                              //       });
                              //     }
                              //   }
                              // }
                            },
                            text: faceBiometricsController.error.isTrue ? "TRY AGAIN" : "CONTINUE",
                            width: const AppSize().screenW() * 0.8,
                            filledColor: const AppColors().branding(17),
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
                        SizedBox(height: const AppSize().flex(15)),
                        if (faceBiometricsController.loading.isFalse && faceBiometricsController.error.isFalse)
                          AppButtons().filledSquareButton(
                            function: () {
                              _cameraController!.startImageStream(_processCameraImage);
                              setState(() {
                                _successPositioned = false;
                                _photoIsTaken = false;
                              });
                            },
                            text: "Retake photo",
                            width: const AppSize().screenW() * 0.8,
                            filledColor: const AppColors().basic(3),
                            borderColors: const AppColors().basic(5),
                            textColor: const AppColors().basic(24),
                          ),
                      ],
                    ),
                  )),
            if (_cameraIsInit && widget.faceValidation["faceTrackingID"])
              Positioned(
                  width: const AppSize().screenW() * 0.9,
                  child: Container(
                    margin: EdgeInsets.only(top: const AppSize().flex(400)),
                    alignment: Alignment.center,
                    child: AppButtons().filledSquareButton(
                      function: () {
                        // if (widget.isTest) {
                        //   Get.offAll(const VerifyPhotoConfirmationTest());
                        // } else {
                        //   Get.offAll(const VerifyPhotoConfirmation(isPushedScreen: true));
                        // }
                      },
                      text: "TRY AGAIN",
                      width: const AppSize().screenW() * 0.8,
                      filledColor: const AppColors().branding(16),
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
                  )),
            Positioned(
                left: const AppSize().flex(5),
                child: Container(
                  margin: EdgeInsets.only(bottom: const AppSize().flex(400)),
                  child: TextButton(
                    onPressed: () {
                      // if (widget.isTest) {
                      //   Get.offAll(const VerifyPhotoConfirmationTest());
                      // } else {
                      //   Get.offAll(const VerifyPhotoConfirmation(isPushedScreen: true));
                      // }
                    },
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
            // AnimatedPositioned(
            //   top: faceBiometricsController.loading.isTrue ? (MediaQuery.of(context).padding.top + 10) : -400,
            //   duration: const Duration(milliseconds: 300),
            //   child: const AlertBanner(
            //     bannerType: TypesOfBanner.inform,
            //     headerText: "Loading",
            //     description: "Please wait...",
            //   ),
            // ),
            // AnimatedPositioned(
            //     duration: const Duration(milliseconds: 300),
            //     curve: Curves.ease,
            //     top: faceBiometricsController.error.isTrue ? (MediaQuery.of(context).padding.top + 10) : -300,
            //     child: AlertBanner(
            //         bannerType: TypesOfBanner.error,
            //         headerText: "ERROR",
            //         description: faceBiometricsController.errorMessage.value,
            //         manualCloseBanner: true,
            //         closeBanner: () {
            //           faceBiometricsController.error.value = false;
            //           faceBiometricsController.errorMessage.value = "";
            //         })),
            // if (widget.completFail)
            //   Positioned(
            //     width: const AppSize().screenW(),
            //     height: const AppSize().screenH(),
            //     child: BlurryContainer(
            //         blur: 3,
            //         elevation: 0,
            //         width: const AppSize().screenW(),
            //         height: const AppSize().screenH(),
            //         color: const AppColors().branding(21),
            //         borderRadius: const BorderRadius.all(Radius.circular(0)),
            //         child: Center(child: CompleteVerificationFail(isTest: widget.isTest))),
            //   )
          ],
        )
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

  void onTakePictureButtonPressed() {
    _cameraController!.setFlashMode(FlashMode.off);
    print("----Resolution preset------${_cameraController!.resolutionPreset}");
    print("----Image format group------${_cameraController!.imageFormatGroup}");
    _cameraController!.getMinExposureOffset().then((value) => print("---Exposure-min------${value}"));
    _cameraController!.getMaxExposureOffset().then((value) => print("---Exposure-max------${value}"));

    _cameraController!.stopImageStream();
    NativeShutterSound.play();
    HapticFeedback.heavyImpact();
    takePicture().then((XFile? file) async {
      if (mounted) {
        setState(() {
          _photoIsTaken = true;
          imageFile = file;
          /* Check image brightness */
          imageFile!.readAsBytes().then((pixels) {
            double colorSum = 0;
            for (int i = 0; i < pixels.length; i++) {
              int pixel = pixels[i];
              int b = (pixel & 0x00FF0000) >> 16;
              int g = (pixel & 0x0000FF00) >> 8;
              int r = (pixel & 0x000000FF);
              var avg = (r + g + b) / 3;
              colorSum += avg;
            }

            print('-----Brightness-------${colorSum / pixels.length}');
            if ((colorSum / pixels.length) > (Platform.isIOS ? 44 : 41)) {
              faceBiometricsController.existErrorText.value = "Ensure good lighting, too dark";
              faceBiometricsController.finalImageExistError.value = true;
            } else if ((colorSum / pixels.length) < (Platform.isIOS ? 40 : 37)) {
              faceBiometricsController.existErrorText.value = "Ensure good lighting, too light";
              faceBiometricsController.finalImageExistError.value = true;
            }
          });
        });
        if (file != null) {
          // getUserData["avatar"] = file.path;
          // getUserData["profile_stage"]["added_photo"] = true;
          // showInSnackBar('Picture saved to ${file.path}');
        }
      }
    }).then((value) {
      faceBiometricsController.staticImageValidation(globalInputImage);
    });
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
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.code}\n${e.description}')));
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }
}
