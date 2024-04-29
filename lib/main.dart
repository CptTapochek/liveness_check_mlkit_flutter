import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:next_vision_flutter_app/src/biometric_verification/biometric_verification.dart';
import 'package:next_vision_flutter_app/src/constants/size.dart';
import 'package:next_vision_flutter_app/src/liveness_check/liveness_check.dart';


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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () => Get.to(const LivenessCheck(isTest: true)),
                    child: Text(
                      "Liveness Check V1",
                      style: TextStyle(
                        fontSize: 18
                      ),
                    )
                  ),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Get.to(const BiometricVerification()),
                    child: Text(
                      "Liveness Check V2",
                      style: TextStyle(
                        fontSize: 18
                      ),
                    )
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
