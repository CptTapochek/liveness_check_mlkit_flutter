import 'dart:async';

import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';


class ColorChanging extends StatefulWidget {
  const ColorChanging({
    Key? key
  }) : super(key: key);

  @override
  State<ColorChanging> createState() => _ColorChangingState();
}

class _ColorChangingState extends State<ColorChanging> {
  static List<Color> colors = [
    Colors.transparent,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.deepPurpleAccent,
    Colors.cyanAccent,
    Colors.greenAccent,
  ];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      Timer.periodic(const Duration(milliseconds: 650), (timer) {
        if(mounted) {
          setState(() => currentIndex++);
        }
        if (currentIndex == (colors.length - 1)) {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: const AppSize().screenH(),
          width: const AppSize().screenW(),
        ),
        for(int index = 0; index < colors.length; index++)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: currentIndex == index ? 0 : const AppSize().screenH(),
            child: Container(
              width: const AppSize().screenW(),
              height: const AppSize().screenH(),
              color: index == 0 ? Colors.transparent : colors[index].withOpacity(0.7),
            ),
          )
      ],
    );
  }
}
