import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';


class TimerLabel extends StatelessWidget {
  const TimerLabel({
    Key? key,
    required this.second
  }) : super(key: key);
  final int second;

  @override
  Widget build(BuildContext context) {
    return Text(
      second.toString(),
      style: TextStyle(
          fontSize: const AppSize().fontFlex(48),
          color: const AppColors().basic(1),
          fontWeight: FontWeight.w500
      ),
    );
  }
}
