import 'package:flutter/material.dart';
import 'package:lucideye/config/navigations.dart';
import 'package:camera/camera.dart';
import 'package:lucideye/features/view/welcomescreen.dart';


late List<CameraDescription> cameras;
Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
