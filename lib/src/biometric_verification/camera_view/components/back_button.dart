import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';

class CameraViewBackButton extends StatelessWidget {
  const CameraViewBackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: Icon(
        Icons.arrow_back_rounded,
        color: const AppColors().basic(24),
        size: const AppSize().flex(28),
      ),
    );
  }
}
