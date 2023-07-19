import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lucideye/features/view/detectionscreens/cameraoverlay.dart';
import 'package:lucideye/main.dart';
import 'dart:ui' as ui;
import '../../../constants/colors.dart';
import 'package:tflite/tflite.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/gestures.dart';

class DetectionScreen_a extends StatefulWidget {
  const DetectionScreen_a({super.key});

  @override
  State<DetectionScreen_a> createState() => _DetectionScreen_aState();
}

enum TtsState { playing, stopped, paused, continued }

class _DetectionScreen_aState extends State<DetectionScreen_a> {
  bool screenactive = false;
  //CAMERA VARIABLES
  late CameraController _cameraController;
  CameraImage? imgCamera;
  bool isWorking = false;
  //model variables
  String result = "";
  String probability = "";
  String _newVoiceText =
      "This is the object detection screen. Double tap to start object detection. Swipe up to use Text Recognition. Long press to exit the app.";

  //--------------------
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  TtsState ttsState = TtsState.stopped;
  //

  //VOICE DATA
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  //

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    // await flutterTts.setVolume(volume);
    // await flutterTts.setSpeechRate(rate);
    // await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }
  //--------------------

  //LOAD MODEL
  loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/aimodels/mobilenet_v1_1.0_224.tflite",
      labels: "assets/aimodels/mobilenet_v1_1.0_224.txt",
    );
    print("========MODEL LOADED=============");
  }

  

  //CAMERA FUNCTIONS
  _initializeCamera() async{
    
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        try {
          _cameraController.startImageStream((imageFromStream) => {
                if (!isWorking)
                  {
                    print("========CAMERA RECORDING============="),
                    isWorking = true,
                    imgCamera = imageFromStream,
                    runModelOnStreamFrames(),
                  }
              });
        } catch (e) {
          print("streams failed");
        }
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        print("CAMERA FAILED ZVEKUTODAROI");
      }
    });
  }

  runModelOnStreamFrames() async {
    print("========MODEL STARTED CHECKING=============");
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 1,
        threshold: 0.1,
      );

      result = "";
      probability = "";
      recognitions!.forEach((response) {
        // result += response["label"] +
        //     " " +
        //     (response["confidence"] as double).toStringAsFixed(2) +
        //     "\n\n";
        result += response["label"] + " Detected";
        probability += "Probability is :" +
            (response["confidence"] * 100 as double).toStringAsFixed(2) +
            "%";
      });
      // _stop();
      setState(() {
        result;
        _newVoiceText = result;
        probability;
      });
      print("========RESULT FOUND=============");
      print("DETECTED OBJECT :" + _newVoiceText);
      await _speak();
      isWorking = false;
    }
  }

  @override
  void initState() {
    setState(() {
      _newVoiceText;
    });
    initTts();   
    loadModel();
    super.initState();
  }

  @override
  void dispose() async {
    
    await _stop();
    await flutterTts.stop();
    await _cameraController.stopImageStream();
    await _cameraController.dispose();
    await Tflite.close();
    screenactive = false;
    super.dispose();
    print("=============removed===============");
    
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    screenactive != true ? _speak() : null;
    
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
                            Positioned(
                              child: QRScannerOverlay(
                                  scanAreaRadius: result == "" ? 25 : 20,
                                  overlayColour: result == ""
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.red.withOpacity(0.3),
                                  lineColor:
                                      result == "" ? Colors.green : Colors.red,
                                  scanAreaHeight: displayWidth * 0.75,
                                  scanAreaWidth: displayWidth * 0.75),
                            ),
                            result == ""
                                ? Container()
                                : Positioned(
                                    child: Center(
                                      child: Container(
                                        width: displayWidth * 0.75 - 35,
                                        height: displayWidth * 0.75 - 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                SizedBox(
                                                  width: displayWidth * 0.1,
                                                  height: displayHeight * 0.1,
                                                  child: Image.asset(
                                                      "assets/neural.png"),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    width: displayWidth * 0.7,
                                                    height:
                                                        displayHeight * 0.32,
                                                    // color: mainColor,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: result != "" &&
                                                            result != null
                                                        ? SingleChildScrollView(
                                                            child: Text(
                                                              result.toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          )
                                                        : Center(
                                                            child: Container(
                                                              width: 50,
                                                              height: 50,
                                                              child:
                                                                  const CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        mainColor),
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Container(
                                                  width: displayWidth * 0.85,
                                                  color: mainColor,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        result = "";
                                                      });
                                                    },
                                                    child: Text(
                                                      'Rescan',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                          ],
                        )
                      : Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(greyd),
                            ),
                          ),
                        ),
                ),
              )
            : GestureDetector(
                onDoubleTap: () {
                  _stop();
                  _initializeCamera();

                  print("=============started camera===============");
                  setState(() {
                    screenactive = true;
                  });
                },
                child: Container(
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
                              'Object Detection',
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
                                height: displayHeight * 0.15,
                                child: Image.asset("assets/obj.png"),
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
                                              height:
                                                  displayHeight * 0.1 * 0.75,
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
