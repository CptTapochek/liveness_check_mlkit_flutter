import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';


class AppButtons {

  TextButton filledRoundButton({
    required function,
    required String icon,
    required String text,
    required Color filledColor,
    required Color textColor,
    required double width,
  }) {
    return TextButton(
      onPressed: function,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(const AppSize().flex(4)))
        )
      ),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width,
          height: const AppSize().flex(38),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: filledColor, borderRadius: BorderRadius.circular(const AppSize().flex(20))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/icons/$icon.svg", width: const AppSize().flex(22)),
              SizedBox(width: const AppSize().flex(10)),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: const AppSize().fontFlex(16),
                  height: 1.1,
                ),
              ),
            ],
          )),
    );
  }

  TextButton outlinedRoundButton({
    required function,
    required String text,
    required Color borderColors,
    required Color textColor,
    required double width,
    bool extraPadding = false,
    Widget? suffix,
  }) {
    return TextButton(
      onPressed: function,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(const AppSize().flex(4)))
        )
      ),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width,
          height: const AppSize().flex(extraPadding ? 48 : 38),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(width: 1, color: borderColors),
              borderRadius: BorderRadius.circular(const AppSize().flex(50))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: const AppSize().fontFlex(16),
                  height: 1.1,
                ),
              ),
              if (suffix != null) suffix
            ],
          )),
    );
  }

  TextButton filledSquareButton({
    required function,
    required String text,
    Color borderColors = Colors.transparent,
    Color textColor = Colors.black,
    Color filledColor = Colors.transparent,
    Color splashColor = Colors.transparent,
    required double width,
    double height = 40,
    Widget? suffix,
    Widget? prefix,
    bool disabled = false,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    bool hasAlignedLeft = false,
    bool hasMultilineText = false,
    String firstText = "",
    String subText = "",
    Color firstTextColor = Colors.black,
    Color subTextColor = Colors.black,
    bool removeAutoFactorScale = false,
    String? semanticLabel
  }) {
    return TextButton(
      onPressed: function,
      isSemanticButton: true,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(splashColor),
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(const AppSize().flex(4)))
        )
      ),
      child: Semantics(
        focusable: true,
        label: (semanticLabel ?? text.toLowerCase()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          width: width * ((width < const AppSize().screenW() * 0.8 && !removeAutoFactorScale) ? factorSize : 1.0),
          height: hasMultilineText ? null : (const AppSize().flex(height) * factorSize),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: disabled ? const AppColors().basic(2) : filledColor,
            border: Border.all(width: 1, color: disabled ? const AppColors().basic(6) : borderColors),
            borderRadius: BorderRadius.circular(const AppSize().flex(4))
          ),
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (prefix != null) prefix,
              if (hasAlignedLeft)
                Expanded(
                  child: buildFilledSquareButtonText(
                    text: text,
                    disabled: disabled,
                    textColor: textColor,
                  ),
                )
              else
                buildFilledSquareButtonText(
                  text: text,
                  disabled: disabled,
                  textColor: textColor,
                ),
              if (hasMultilineText)
                buildFilledSquareButtonMultilineText(
                  firstText: firstText,
                  subText: subText,
                  firstTextColor: firstTextColor,
                  subTextColor: subTextColor,
                ),
              if (suffix != null) suffix
            ],
          )
        ),
      ),
    );
  }

  Widget buildFilledSquareButtonText({
    required String text,
    required Color textColor,
    required bool disabled,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: const AppSize().screenW() * 0.7),
      child: Text(
        text,
        semanticsLabel: "",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: disabled ? const AppColors().basic(16) : textColor,
          fontSize: const AppSize().fontFlex(16),
          height: 1.1,
        ),
      ),
    );
  }

  Widget buildFilledSquareButtonMultilineText({
    required String firstText,
    required String subText,
    required Color firstTextColor,
    required Color subTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            firstText,
            semanticsLabel: "",
            style: TextStyle(
              color: firstTextColor,
              fontSize: const AppSize().fontFlex(16),
              height: 1.1,
            ),
          ),
          Text(
            subText,
            semanticsLabel: "${firstText.toLowerCase()}, ${subText.toLowerCase()}",
            style: TextStyle(
              color: subTextColor,
              fontSize: const AppSize().fontFlex(16),
              decoration: TextDecoration.underline,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  TextButton textButton({
    required function,
    required String text,
    Color textColor = Colors.black,
    Widget? suffix,
    bool disabled = false,
    required EdgeInsets padding,
  }) {
    return TextButton(
        onPressed: function,
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all<EdgeInsets>(padding),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(const AppSize().flex(4)))
          )
        ),
        child: Semantics(
          focusable: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                semanticsLabel: text.toLowerCase(),
                style: TextStyle(
                  color: disabled ? const AppColors().basic(12) : textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: const AppSize().fontFlex(16),
                  height: 1.1,
                ),
              ),
              if (suffix != null) suffix
            ],
          ),
        )
    );
  }
}
