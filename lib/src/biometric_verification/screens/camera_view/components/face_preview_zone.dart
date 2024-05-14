import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/move_face_on_median_plane.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';


class FacePreviewZone extends StatelessWidget {
  const FacePreviewZone({
    Key? key,
    required this.error,
    required this.distanceCalibration
  }) : super(key: key);
  final bool error;
  final Map distanceCalibration;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        !error ? const AppColors().basic(1) : const AppColors().danger(13),
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
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + const AppSize().flex(30)
            ),
            child: Align(
                alignment: Alignment.topCenter,
                child: ClipOval(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    height: const AppSize().screenW() * (distanceCalibration["process"] == CurrentProcess.longDistance ? 0.95 : 1.2),
                    width: const AppSize().screenW() * (distanceCalibration["process"] == CurrentProcess.longDistance ? 0.65 : 0.8),
                    color: Colors.red,
                  ),
                )
            ),
          )
        ],
      ),
    );
  }
}
