import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucideye/features/view/detectionscreens/cameraoverlay.dart';
import 'package:lucideye/main.dart';
import '../../../constants/colors.dart';
import 'package:google_ml_kit/google_ml_kit.dart';


class DetectionScreen_b extends StatefulWidget {
  const DetectionScreen_b({super.key});

  @override
  State<DetectionScreen_b> createState() => _DetectionScreen_bState();
}

class _DetectionScreen_bState extends State<DetectionScreen_b> {
  bool screenactive = false;
  //CAMERA VARIABLES
  late CameraController _cameraController;
  CameraImage? imgCamera;
  bool isWorking = false;

  //TEXT READING VARIABLES
  final textRecognizer = TextRecognizer();
  String recognizedText = "";

  //CAMERA FUNCTIONS
  _initializeCamera() {
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        
        
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        print("CAMERA FAILED ZVEKUTODAROoox");
      }
    });
  }

  //TAKING IMAGE TO BE SCANNED
  Future<void> _scanImage() async {
   if (_cameraController != null && _cameraController.value.isInitialized) {
    try {
      final XFile pictureFile = await _cameraController.takePicture();
      // final file = File(pictureFile.path);
      // final inputImage = InputImage.fromFile(file);
      // recognizedText = await textRecognizer.processImage(inputImage).toString();
      print("=============DONE SCANNING===============");
      //
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('An error occurred when scanning text, please try again'),
        ),
      );
    }
   }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    _cameraController.stopImageStream();
    _cameraController.dispose();
    textRecognizer.close();
    screenactive = false;
    print("=============removed===============");
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        screenactive
            ? Positioned(
                child: Container(
                  width: displayWidth,
                  height: displayHeight,
                  child: _cameraController.value.isInitialized
                      ? Stack(
                          children: [
                            Container(
                              width: displayWidth,
                              height: displayHeight,
                              child: AspectRatio(
                                aspectRatio:
                                    _cameraController.value.aspectRatio,
                                child: CameraPreview(_cameraController),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print('Single tap');
                              },
                              onDoubleTap: () {
                                _scanImage();
                                print('Double tap');
                              },
                              onLongPress: () {
                                print('Long press');
                              },
                              child: QRScannerOverlay(
                                  scanAreaRadius: 20,
                                  overlayColour: Colors.black.withOpacity(0.5),
                                  lineColor: Colors.black.withOpacity(0.5),
                                  scanAreaHeight: displayHeight * 0.65,
                                  scanAreaWidth: displayWidth * 0.7),
                            ),
                            recognizedText !=""?
                            Positioned(
                                child: Center(
                              child: Container(
                                width: displayWidth * 0.75 - 35,
                                height: displayHeight * 0.65 - 25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.7),
                                      Colors.grey.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.grey.withOpacity(0.3),
                                            Colors.white.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: displayWidth * 0.2,
                                            height: displayHeight * 0.1,
                                            child: Image.asset(
                                                "assets/neural.png"),
                                          ),
                                          Container(
                                            width: displayWidth * 0.7,
                                            height: displayHeight * 0.1,
                                            child: Center(
                                              child: Text(
                                                recognizedText,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: displayWidth * 0.7,
                                            height: displayHeight * 0.32,
                                            color: mainColor,
                                          ),
                                          Container(
                                            width: displayWidth * 0.7,
                                            child: TextButton(
                                                onPressed: () {},
                                                child: Text(
                                                  'Rescan',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: mainColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                            ))
                            :Container()
                          ],
                        )
                      : Center(
                          child: Container(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(greyd))),
                        ),
                ),
              )
            : Container(
                padding: EdgeInsets.only(
                    top: displayHeight * 0.05, bottom: displayHeight * 0.15),
                width: displayWidth,
                height: displayHeight,
                color: white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: displayHeight * 0.05,
                          bottom: displayHeight * 0.03,
                          left: 20),
                      width: displayWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Text Recognition',
                            style: TextStyle(
                                fontSize: 30,
                                color: greyd,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Shake your phone or press start to start your camera',
                            style: TextStyle(fontSize: 18, color: greyb),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: displayWidth,
                      height: displayHeight * 0.45,
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              width: displayWidth,
                              height: displayHeight * 0.2,
                              child: Image.asset("assets/document.png"),
                            ),
                          ),
                          Positioned(
                            child: Center(
                              child: CustomPaint(
                                  painter: BorderPainter(),
                                  child: Container(
                                    width: displayHeight * 0.3 * 0.75,
                                    height: displayHeight * 0.3 * 0.75,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Container(
                                            width: displayHeight * 0.1 * 0.75,
                                            height: displayHeight * 0.1 * 0.75,
                                            decoration: BoxDecoration(
                                              color: greya.withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: greyd,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          _initializeCamera();
                          // _initializeCamera(cameras[0]);
                          print("=============started camera===============");
                          setState(() {
                            screenactive = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: greyd,
                          shadowColor: greyd,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: Size(displayWidth * 0.8, 50),
                        ),
                        child: Text(
                          'Start Camera',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )
      ],
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height;
    double sw = size.width;
    double cornerSide = sh * 0.1;

    Paint paint = Paint()
      ..color = greyd
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path()
      ..moveTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..moveTo(0, sh - cornerSide)
      ..quadraticBezierTo(0, sh, cornerSide, sh)
      ..moveTo(sw - cornerSide, sh)
      ..quadraticBezierTo(sw, sh, sw, sh - cornerSide)
      ..moveTo(sw, cornerSide)
      ..quadraticBezierTo(sw, 0, sw - cornerSide, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}
