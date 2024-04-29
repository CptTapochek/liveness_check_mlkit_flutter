import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    Key? key,
    this.progress = 0.0,
    this.errorActive = false,
  }) : super(key: key);
  final double progress;
  final bool errorActive; 

  @override
  Widget build(BuildContext context) {
    return Container(
        width: const AppSize().screenW() * 0.8,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: const AppSize().screenW() * 0.8,
              height: const AppSize().flex(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(width: 1, color: const AppColors().basic(24))
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: (const AppSize().screenW() * 0.8 - 2) * progress,
              height: const AppSize().flex(20) - 2,
              color: errorActive ? const AppColors().basic(1) : const AppColors().branding(16),
            )
          ],
        )
    );
  }
}
