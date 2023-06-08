import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:lucideye/features/view/detectionscreens/cameraoverlay.dart';
import 'package:lucideye/main.dart';
import '../../../constants/colors.dart';

class DetectionScreen_c extends StatefulWidget {
  const DetectionScreen_c({super.key});

  @override
  State<DetectionScreen_c> createState() => _DetectionScreen_cState();
}

class _DetectionScreen_cState extends State<DetectionScreen_c> {
  bool screenactive = false;
  //CAMERA VARIABLES
  late CameraController _cameraController;
  CameraImage? imgCamera;
  bool isWorking = false;

  //CAMERA FUNCTIONS
  _initializeCamera() {
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        try{
          _cameraController.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  print("========CAMERA RECORDING============="),
                  isWorking = true,
                  imgCamera = imageFromStream,
                  
                }
            });
        } catch (e){
          print("===============STREAMING FAILED==============");
        }
        print("========CAMERA STARTED=============");
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        print("CAMERA FAILED ZVEKUTODAROI");
      }
    });
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
                                
                                print('Double tap');
                              },
                              onLongPress: () {
                                print('Long press');
                              },
                              child: Positioned(
                                child: QRScannerOverlay(
                                  scanAreaRadius: 1,
                                  overlayColour: Colors.black.withOpacity(0.5),
                                  lineColor: mainColor,
                                  scanAreaHeight:displayHeight*0.3,
                                  scanAreaWidth:displayWidth*0.85
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(greyd)
                          )),
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
                            'Currency Detection',
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
                              height: displayHeight * 0.12,
                              child: Image.asset("assets/money_1.png"),
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
    double sh = size.height; // for convenient shortage
    double sw = size.width; // for convenient shortage
    double cornerSide = sh * 0.1; // desirable value for corners side

    Paint paint = Paint()
      ..color = Colors.grey
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
