import 'dart:async';
import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/components/processes/move_face_on_median_plane.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';

class TurnHeadArrows extends StatefulWidget {
  const TurnHeadArrows({
    Key? key,
    required this.turnDirection
  }) : super(key: key);
  final TurnHeadDirections turnDirection;

  @override
  State<TurnHeadArrows> createState() => _TurnHeadArrowsState();
}

class _TurnHeadArrowsState extends State<TurnHeadArrows> {
  Timer? _timer;
  bool changeDirection = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 700), (Timer timer) {
      setState(() => changeDirection = !changeDirection);
    },
    );
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: const AppSize().screenW(),
      child: Row(
        children: [
          if(widget.turnDirection == TurnHeadDirections.left)
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              margin: EdgeInsets.only(left: changeDirection ? 0 : const AppSize().flex(40)),
              child: Icon(
                Icons.arrow_back_rounded,
                color: const AppColors().success(15),
                size: const AppSize().flex(120),
              ),
            ),
          const Spacer(),
          if(widget.turnDirection == TurnHeadDirections.right)
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              margin: EdgeInsets.only(right: changeDirection ? 0 : const AppSize().flex(40)),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: const AppColors().success(15),
                size: const AppSize().flex(120),
              ),
            ),
        ],
      ),
    );
  }
}
