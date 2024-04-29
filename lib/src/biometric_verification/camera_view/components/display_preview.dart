import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DisplayPreview extends StatelessWidget {
  const DisplayPreview({
    Key? key,
    this.cameraController,
  }) : super(key: key);
  final CameraController? cameraController;

  @override
  Widget build(BuildContext context) {
    cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * cameraController!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top
      ),
      child: Transform.scale(
        scale: scale * 0.7,
        alignment: Alignment.topCenter,
        child: Align(
            alignment: Alignment.topCenter,
            child: CameraPreview(cameraController!)
        ),
      ),
    );
  }
}
