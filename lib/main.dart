import 'package:flutter/material.dart';
import 'package:lucideye/config/navigations.dart';
import 'package:camera/camera.dart';
import 'package:lucideye/features/view/welcomescreen.dart';
import 'package:permission_handler/permission_handler.dart';


late List<CameraDescription> cameras;
Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  checkAndRequestPermissions();
  cameras = await availableCameras();
  runApp( MyApp());
}

// void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUCID EYE',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}

Future<void> checkAndRequestPermissions() async {

  // Check microphone permission
  if (!(await Permission.microphone.isGranted)) {
    await Permission.microphone.request();
  }

  // Check audio permission
  if (!(await Permission.audio.isGranted)) {
    await Permission.audio.request();
  }

  // Check camera permission
  if (!(await Permission.camera.isGranted)) {
    await Permission.camera.request();
  }

  // Check location permission
  if (!(await Permission.location.isGranted)) {
    await Permission.location.request();
  }

  // Check Bluetooth permission
  if (!(await Permission.bluetooth.isGranted)) {
    await Permission.bluetooth.request();
  }
}