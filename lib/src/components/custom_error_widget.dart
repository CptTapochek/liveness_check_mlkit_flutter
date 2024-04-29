import 'package:flutter/material.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';


class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.engineering_rounded, color: const AppColors().branding(16), size: 72),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Oops, sorry but there was a technical error, we are trying to fix it as soon as possible.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}
