import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/liveness.dart';
import 'package:next_vision_flutter_app/src/constants/colors.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';


List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const AppSize().initAppSize();
    return GetMaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NextVision'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SizedBox(
          height: const AppSize().screenH(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.to(Liveness(rootWidget: Home())),
                    child: const Text(
                      "Liveness Check",
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Andrei Bozu",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}
