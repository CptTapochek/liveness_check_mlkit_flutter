import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';

class InformLabel extends StatelessWidget {
  const InformLabel({
    Key? key,
    this.text = "",
    this.errorActive = false,
  }) : super(key: key);
  final String text;
  final bool errorActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: const AppSize().screenW() * 0.8,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: errorActive ? const AppColors().basic(1) : const AppColors().branding(16),
          fontSize: const AppSize().fontFlex(18),
          fontWeight: FontWeight.w700
        ),
      ),
    );
  }
}
