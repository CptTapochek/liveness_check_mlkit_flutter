import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:next_vision_flutter_app/main.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';


class CompleteVerificationFail extends StatefulWidget {
  const CompleteVerificationFail({
    this.isTest = false
  });
  final bool isTest;

  @override
  State<CompleteVerificationFail> createState() => _CompleteVerificationFailState();
}

class _CompleteVerificationFailState extends State<CompleteVerificationFail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: const AppSize().screenW() * 0.9,
      height: const AppSize().screenW() * 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(const AppSize().flex(4)),
        color: const AppColors().basic(1)
      ),
      padding: EdgeInsets.only(top: const AppSize().flex(15)),
      child: Column(
        children: [
          Text(
            "Verification failed",
            style: TextStyle(
              color: const AppColors().danger(15),
              fontSize: const AppSize().fontFlex(21),
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          SizedBox(height: const AppSize().flex(25)),
          Center(
            child: SizedBox(
              width: const AppSize().screenW() * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ensure a good quality photo:",
                    style: TextStyle(
                      color: const AppColors().basic(24),
                      fontSize: const AppSize().fontFlex(16),
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: const AppSize().flex(15)),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/image.svg",
                        color: const AppColors().basic(24),
                        width: const AppSize().flex(18),
                      ),
                      SizedBox(width: const AppSize().flex(10)),
                      Text(
                        "Clean background",
                        style: TextStyle(
                          color: const AppColors().basic(24),
                          fontSize: const AppSize().fontFlex(14),
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: const AppSize().flex(5)),
                  Text(
                    "Ensure a clean background, like a white wall.",
                    style: TextStyle(
                      color: const AppColors().basic(24),
                      fontSize: const AppSize().fontFlex(16),
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: const AppSize().flex(20)),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/your-photo-light.svg",
                        color: const AppColors().basic(24),
                        width: const AppSize().flex(18),
                      ),
                      SizedBox(width: const AppSize().flex(10)),
                      Text(
                        "Good lighting",
                        style: TextStyle(
                          color: const AppColors().basic(24),
                          fontSize: const AppSize().fontFlex(14),
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: const AppSize().flex(5)),
                  Text(
                      "Avoid shadows, light reflections and colored lights.",
                    style: TextStyle(
                      color: const AppColors().basic(24),
                      fontSize: const AppSize().fontFlex(16),
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: const AppSize().flex(20)),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/your-photo-face.svg",
                        color: const AppColors().basic(24),
                        width: const AppSize().flex(18),
                      ),
                      SizedBox(width: const AppSize().flex(10)),
                      Text(
                        "Visible face",
                        style: TextStyle(
                          color: const AppColors().basic(24),
                          fontSize: const AppSize().fontFlex(14),
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: const AppSize().flex(5)),
                  Text(
                    "No head coverings or glasses, neutral expression",
                    style: TextStyle(
                      color: const AppColors().basic(24),
                      fontSize: const AppSize().fontFlex(16),
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: const AppSize().flex(20)),
          Text(
            "Do you want to try again?",
            style: TextStyle(
              color: const AppColors().basic(24),
              fontSize: const AppSize().fontFlex(16),
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: () => Get.offAll(Home()),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
                ),
                child: Container(
                  alignment: Alignment.center,
                  width: (const AppSize().screenW() * 0.9) / 2,
                  height: const AppSize().flex(48),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(const AppSize().flex(4)),
                    ),
                  ),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(
                      color: const AppColors().basic(24),
                      fontWeight: FontWeight.w400,
                      fontSize: const AppSize().fontFlex(16),
                      height: 1,
                    ),
                  ),
                )
              ),
              TextButton(
                onPressed: () {
                  // if(widget.isTest) {
                  //   Get.offAll(const VerifyPhotoConfirmationTest());
                  // } else {
                  //   Get.offAll(const VerifyPhotoConfirmation(isPushedScreen: true));
                  // }
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
                ),
                child: Container(
                  alignment: Alignment.center,
                  width: (const AppSize().screenW() * 0.9) / 2,
                  height: const AppSize().flex(48),
                  decoration: BoxDecoration(
                    color: const AppColors().branding(16),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(const AppSize().flex(4)),
                    ),
                  ),
                  child: Text(
                    "TRY AGAIN",
                    style: TextStyle(
                      color: const AppColors().basic(1),
                      fontWeight: FontWeight.w400,
                      fontSize: const AppSize().fontFlex(16),
                      height: 1,
                    ),
                  ),
                )
              )
            ],
          )
        ],
      ),
    );
  }
}
