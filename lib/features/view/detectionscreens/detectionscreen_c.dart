import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:lucideye/features/view/detectionscreens/cameraoverlay.dart';
import 'package:lucideye/main.dart';
import 'package:tflite/tflite.dart';
import '../../../constants/colors.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/gestures.dart';

class DetectionScreen_c extends StatefulWidget {
  const DetectionScreen_c({super.key});

  @override
  State<DetectionScreen_c> createState() => _DetectionScreen_cState();
}

enum TtsState { playing, stopped, paused, continued }

class _DetectionScreen_cState extends State<DetectionScreen_c> {
  bool screenactive = false;
  //CAMERA VARIABLES
  late CameraController _cameraController;
  CameraImage? imgCamera;
  bool isWorking = false;
  String _newVoiceText =
      "This is the Currency detection screen. Double tap to start Currency detection. Swipe down to use Text Recognition . Long press to exit the app.";
  //NOTE Detection
  Image? img;
  String result = "";
  // ignore: prefer_typing_uninitialized_variables
  var noteStatusIdentified;
  double result_confidence = 0;
  // final FlutterTts _flutterTts = FlutterTts();
  String? forTts;
  double total = 0;
  late String imagePath;
  bool scanning = false;

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

  //CAMERA FUNCTIONS
  _initializeCamera() async {
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        print("CAMERA FAILED ZVEKUTODAROoox");
      }
    });
  }

  //TAKING IMAGE TO BE SCANNED
  Future<void> _scanImage() async {
    setState(() {
      scanning = true;
    });
    if (_cameraController != null && _cameraController.value.isInitialized) {
      try {
        // XFile pictureFile = await _cameraController.takePicture();
        // Uint8List bytes = await pictureFile.readAsBytes();
        if (_cameraController == null) return;

        final pictureFile = await _cameraController!.takePicture();

        // final inputImage = InputImage.fromFile(file);
        // final recognizedTextIn = await textRecognizer.processImage(inputImage);
        setState(() {
          imagePath = pictureFile.path;
          // recognizedText = recognizedTextIn.text;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'An error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\n'),
          ),
        );
      }
    }
  }

  //LOADING MODEL FOR DETECTION
  loadModel() async {
    await Tflite.loadModel(
      model: "assets/aimodels/model_unquant.tflite",
      labels: "assets/aimodels/labels.txt",
    );
  }

  //IMAGE DETECTION
  classifyImage(String imagePath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    //-------------------------------------------------------------------------------------------------------
    result = "";

    recognitions?.forEach((response) {
      result += response["label"];
      result_confidence = response["confidence"] * 100;
    });

    setState(() {
      result;
      result_confidence;
    });

    if (result_confidence > 99.5) {
      noteStatusIdentified = true;
      if (result == "0 1 US Dollar") {
        setState(() {
          total += 1;
          result = "1 US Dollar";
          forTts = "1 U.S Dollar, your total is now $total dollars";
          _newVoiceText = forTts!;
        });

        await _speak();
      } else if (result == "1 2 US Dollars") {
        setState(() {
          total += 2;
          result = "2 US Dollars";
          forTts = "2 U.S Dollars, your total is now $total dollars";
          _newVoiceText = forTts!;
        });
        await _speak();
      } else if (result == "2 5 US Dollars") {
        setState(() {
          total += 5;
          result = "5 US Dollars";
          forTts = "5 U.S Dollars, your total is now $total dollars";
          _newVoiceText = forTts!;
        });
        await _speak();
      } else if (result == "3 10 US Dollars") {
        setState(() {
          total += 10;
          result = "10 US Dollars";
          forTts = "10 U.S Dollars, your total is now $total dollars";
          _newVoiceText = forTts!;
        });
        await _speak();
      } else if (result == "4 20 US Dollars") {
        setState(() {
          total += 20;
          result = "20 US Dollars";
          forTts = "20 U.S Dollars, your total is now $total dollars";
          _newVoiceText = forTts!;
        });
        await _speak();
      } else if (result == "5 50 US Dollars") {
        setState(() {
          total += 50;
          result = "50 US Dollars";
          forTts = "50 U.S Dollars, your total is now $total dollars";
          _newVoiceText = forTts!;
        });
        await _speak();
      } else if (result == "6 100 US Dollars") {
        setState(() {
          total += 100;
          result = "100 US Dollars";
          forTts = "100 U.S Dollars, your total is now $total dollars";
          _newVoiceText = forTts!;
        });
        await _speak();
      }
    } else if (result_confidence >= 98 && result_confidence <= 99.5) {
      setState(() {
        noteStatusIdentified = false;
        result = "Please Rescan";
        forTts = "The note is not clear enough, Please long press the screen center to rescan";
        _newVoiceText = forTts!;
      });
      await _speak();
    } else {
      setState(() {
        noteStatusIdentified = false;
        result = "Please Rescan";
        forTts = "No note found, Please long press the screen center to rescan";
        _newVoiceText = forTts!;
      });
      await _speak();
    }

    //-------------------------------------------------------------------------------------------------------
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    setState(() {
      _newVoiceText;
    });
    initTts();
  }

  @override
  void dispose() async {
    
    await _stop();
    await flutterTts.stop();
    // flutterTts.stop();
    _cameraController.stopImageStream();
    _cameraController.dispose();
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
                            GestureDetector(
                              onTap: () {
                                print('Single tap');
                              },
                              onDoubleTap: () async {
                                print('Double tap');
                                await _scanImage();
                                await classifyImage(imagePath);
                              },
                              onLongPress: () {
                                print('Long press');
                                total = 0;
                                result = "";
                              },
                              child: Positioned(
                                child: QRScannerOverlay(
                                    scanAreaRadius: 1,
                                    overlayColour:
                                        Colors.black.withOpacity(0.5),
                                    lineColor: mainColor,
                                    scanAreaHeight: displayHeight * 0.3,
                                    scanAreaWidth: displayWidth * 0.85),
                              ),
                            ),
                            result != "" && result != null
                                ? GestureDetector(
                                    onLongPress: () async {
                                      await _stop();
                                      setState(() {
                                        scanning = false;
                                        result = "";
                                        _newVoiceText =
                                            "Double Tap the screen to scan text and read it aloud.";
                                      });
                                      await _speak();
                                    },
                                    child: Positioned(
                                      child: Center(
                                        child: Container(
                                          width: displayWidth * 0.85 - 35,
                                          height: displayHeight * 0.3 - 25,
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
                                                    Colors.grey
                                                        .withOpacity(0.3),
                                                    Colors.white
                                                        .withOpacity(0.7),
                                                  ],
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                                forTts
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
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
                                                                  valueColor: AlwaysStoppedAnimation<
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
                                                          scanning = false;
                                                          result = "";
                                                        });
                                                      },
                                                      child: Text(
                                                        'Rescan',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container()
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
            : GestureDetector(
                onDoubleTap: () async {
                  await _stop();

                  _initializeCamera();
                  setState(() {
                    _newVoiceText =
                        "Double Tap the screen to scan notes and read them aloud.";
                  });

                  print("=============started camera===============");
                  setState(() {
                    screenactive = true;
                  });
                  await _speak();
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
                            _stop();
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
