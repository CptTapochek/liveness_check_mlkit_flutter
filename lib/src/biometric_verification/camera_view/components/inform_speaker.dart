import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';

class InformSpeaker extends StatelessWidget {
  const InformSpeaker({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: const AppSize().flex(400)),
      child: TextButton(
          onPressed: () {},
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: SvgPicture.asset(
            "assets/icons/speaker.svg",
            width: const AppSize().flex(24),
          )
      ),
    );
  }
}
