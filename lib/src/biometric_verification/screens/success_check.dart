import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:next_vision_flutter_app/src/constants/app_bar_state.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';

class SuccessCheck extends StatefulWidget {
  const SuccessCheck({
    Key? key,
    required this.rootWidget,
    required this.debugData
  }) : super(key: key);
  final Widget rootWidget;
  final List debugData;

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<SuccessCheck> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarState().dark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/success-bold.svg",
              width: const AppSize().flex(160),
            ),
            SizedBox(height: const AppSize().flex(20)),
            for(int index = 0; index < widget.debugData.length; index++)
              Text(
                "${widget.debugData[index]["title"]}: ${widget.debugData[index]["value"]}"
              ),
            SizedBox(height: const AppSize().flex(20)),
            TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget.rootWidget), (route) => false),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(const AppSize().flex(4)))
                  )
                ),
                child: Container(
                  width: const AppSize().screenW() * 0.7,
                  height: const AppSize().flex(48),
                  decoration: BoxDecoration(
                    color: const AppColors().branding(17),
                    borderRadius: BorderRadius.circular(const AppSize().flex(4)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "CONTINUE",
                    style: TextStyle(
                      color: const AppColors().basic(1),
                      fontSize: const AppSize().fontFlex(16),
                      height: 1
                    ),
                  ),
                )
            )
          ],
        ),
      )
    );
  }
}
