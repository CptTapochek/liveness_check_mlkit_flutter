import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/liveness.dart';
import 'package:next_vision_flutter_app/src/constants/app_bar_state.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';


class FraudDetected extends StatefulWidget {
  const FraudDetected({
    Key? key,
    required this.rootWidget,
    required this.debugData,
  }) : super(key: key);
  final Widget rootWidget;
  final List debugData;

  @override
  State<FraudDetected> createState() => _FraudDetectedState();
}

class _FraudDetectedState extends State<FraudDetected> {

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      if(kDebugMode) {
        for(int index = 0; index < widget.debugData.length; index++) {
          print("⏩⏩⏩ ${widget.debugData[index]["title"]}: ${widget.debugData[index]["value"]}");
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget photoContainer({
      required bool isIdealPose,
      required String text,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: const AppSize().screenW() * 0.28,
            height: const AppSize().screenW() * 0.28 * 1.77,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(const AppSize().flex(4))
            ),
          ),
          Text(
            text,
            style: TextStyle(
              height: 1.5,
              color: const AppColors().basic(24),
              fontSize: const AppSize().fontFlex(12)
            ),
          )
        ],
      );
    }

    Widget tipsWidget({
      required String title,
      required String description,
      required String icon,
    }) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/icons/$icon.svg",
                width: const AppSize().fontFlex(16),
                colorFilter: ColorFilter.mode(
                  const AppColors().basic(22),
                  BlendMode.dstIn
                ),
              ),
              Text(
                " $title",
                style: TextStyle(
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontSize: const AppSize().fontFlex(14),
                    color: const AppColors().basic(22)
                ),
              ),
            ],
          ),
          SizedBox(height: const AppSize().flex(4)),
          SizedBox(
            width: double.infinity,
            child: Text(
              description,
              style: TextStyle(
                  height: 1,
                  fontSize: const AppSize().fontFlex(14),
                  fontWeight: FontWeight.w400,
                  color: const AppColors().basic(22)
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarState().light,
      backgroundColor: const AppColors().branding(21),
      body: Center(
        child: Container(
          width: const AppSize().screenW() * 0.9,
          height: const AppSize().screenH() * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(const AppSize().flex(4)),
            color: const AppColors().basic(1)
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(const AppSize().flex(15)),
                child: Column(
                  children: [
                    Text(
                      "Verification failed",
                      style: TextStyle(
                        height: 1,
                        color: const AppColors().branding(16),
                        fontSize: const AppSize().fontFlex(18),
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    SizedBox(height: const AppSize().flex(10)),
                    Text(
                      "Please try again and make sure the selfie video is of good quality.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1,
                        color: const AppColors().basic(24),
                        fontSize: const AppSize().fontFlex(14)
                      ),
                    ),
                    SizedBox(height: const AppSize().flex(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        photoContainer(
                          isIdealPose: false,
                          text: "Your selfie",
                        ),
                        photoContainer(
                          isIdealPose: false,
                          text: "Ideal pose",
                        ),
                      ],
                    ),
                    SizedBox(height: const AppSize().flex(12)),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Tips for correct verification:",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          height: 1,
                          fontWeight: FontWeight.w600,
                          fontSize: const AppSize().fontFlex(14),
                          color: const AppColors().branding(17)
                        ),
                      ),
                    ),
                    SizedBox(height: const AppSize().flex(8)),
                    Column(
                      children: [
                        tipsWidget(
                          title: "Good lighting",
                          description: "Avoid shadows, blank background.",
                          icon: "your-photo-light"
                        ),
                        SizedBox(height: const AppSize().flex(10)),
                        tipsWidget(
                          title: "Visible face",
                          description: "Do not wear glasses, hat or other things that may cover your face.",
                          icon: "your-photo-face"
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget.rootWidget), (route) => false),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                    ),
                    child: Container(
                      width: const AppSize().screenW() * 0.45,
                      height: const AppSize().flex(48),
                      alignment: Alignment.center,
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          fontSize: const AppSize().fontFlex(16),
                          color: const AppColors().basic(18),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => Liveness(rootWidget: widget.rootWidget)),
                      (route) => false
                    ),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                    ),
                    child: Container(
                      width: const AppSize().screenW() * 0.45,
                      height: const AppSize().flex(48),
                      decoration: BoxDecoration(
                        color: const AppColors().branding(17),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(const AppSize().flex(4)),
                          bottomRight: Radius.circular(const AppSize().flex(4)),
                        )
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "TRY AGAIN",
                        style: TextStyle(
                          fontSize: const AppSize().fontFlex(16),
                          color: const AppColors().basic(1),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}
