import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucideye/features/view/detectionscreens/cameraoverlay.dart';
import 'package:lucideye/main.dart';
import '../../../constants/colors.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/gestures.dart';

String _newVoiceText =
    "This is the Text recognition screen. Double tap to start Text Recognition. Swipe up to use Currency Detection. Long press to exit the app.";

class DetectionScreen_b extends StatefulWidget {
  const DetectionScreen_b({super.key});

  @override
  State<DetectionScreen_b> createState() => _DetectionScreen_bState();
}

enum TtsState { playing, stopped, paused, continued }

class _DetectionScreen_bState extends State<DetectionScreen_b> {
  String? engine;
  //--------------------
  late FlutterTts flutterTts;

  CameraImage? imgCamera;
  bool isWorking = false;
  String? language;
  double pitch = 1.0;
  double rate = 0.5;
  String? recognizedText;
  bool scanning = false;
  bool screenactive = false;
  //TEXT READING VARIABLES
  final textRecognizer = TextRecognizer();

  TtsState ttsState = TtsState.stopped;
  double volume = 0.5;

  //CAMERA VARIABLES
  late CameraController _cameraController;

  late Uint8List _imageBytes;

  @override
  void dispose() async {
    
    await _stop();
    await flutterTts.stop();
    _cameraController.stopImageStream();
    _cameraController.dispose();
    textRecognizer.close();
    screenactive = false;
    super.dispose();
    print("=============removed===============");
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _newVoiceText;
    });
    initTts();
  }

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

  //CAMERA FUNCTIONS
  _initializeCamera() async {
    _stop();
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
    if (_cameraController != null && _cameraController.value.isInitialized) {
      try {
        // XFile pictureFile = await _cameraController.takePicture();
        // Uint8List bytes = await pictureFile.readAsBytes();
        if (_cameraController == null) return;

        final pictureFile = await _cameraController!.takePicture();
        final file = File(pictureFile.path);
        final inputImage = InputImage.fromFile(file);
        final recognizedTextIn = await textRecognizer.processImage(inputImage);
        setState(() {
          recognizedText = recognizedTextIn.text;
          if (recognizedText != null && recognizedText != "") {
            _newVoiceText = recognizedText!;
          } else {
            _newVoiceText =
                "No text has been detected, please position your camera correctly, Please long press the screen center to rescan";
                recognizedText =_newVoiceText;
          }
        });
        _speak();
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
                              onDoubleTap: () {
                                _scanImage();
                                setState(() {
                                  scanning = true;
                                });
                                print('Double tap');
                              },
                              onLongPress: () {
                                setState(() {
                                  scanning = false;
                                  recognizedText = null;
                                });
                                print('Long press');
                              },
                              child: QRScannerOverlay(
                                  scanAreaRadius: 1,
                                  overlayColour: Colors.black.withOpacity(0.5),
                                  lineColor: mainColor.withOpacity(0.5),
                                  scanAreaHeight: displayHeight * 0.65,
                                  scanAreaWidth: displayWidth * 0.7),
                            ),
                            scanning
                                ? GestureDetector(
                                    onLongPress: () async{
                                      await _stop();
                                      setState(() {
                                        scanning = false;
                                        recognizedText = null;
                                        _newVoiceText = "Double Tap the screen to scan text and read it aloud.";
                                      });
                                      await _speak();
                                    },
                                    child: Positioned(
                                      child: Center(
                                        child: Container(
                                          width: displayWidth * 0.75 - 35,
                                          height: displayHeight * 0.65 - 25,
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
                                                    width: displayWidth * 0.2,
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
                                                      child: recognizedText !=
                                                                  "" &&
                                                              recognizedText !=
                                                                  null
                                                          ? SingleChildScrollView(
                                                              child: Text(
                                                                recognizedText
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
                                                    width: displayWidth * 0.7,
                                                    color: mainColor,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          scanning = false;
                                                          recognizedText = null;
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
                              valueColor: AlwaysStoppedAnimation<Color>(greyd),
                            ),
                          ),
                        ),
                ),
              )
            : GestureDetector(
                onDoubleTap: () async {
                  _stop();

                  _initializeCamera();
                  setState(() {
                    _newVoiceText =
                        "Double Tap the screen to scan text and read it aloud.";
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
                  color: mainColor,
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
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Shake your phone or press start to start your camera',
                              style:
                                  TextStyle(fontSize: 18, color: primaryColor),
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
                                      height: displayHeight * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                              width: displayHeight * 0.1 * 0.8,
                                              height: displayHeight * 0.1,
                                              decoration: BoxDecoration(
                                                color: greya.withOpacity(0.7),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: primaryColor,
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

                            print("=============started camera===============");
                            setState(() {
                              screenactive = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
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
      ..color = primaryColor
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
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;
}
