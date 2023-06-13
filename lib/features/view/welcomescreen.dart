import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucideye/config/navigations.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

enum TtsState { playing, stopped, paused, continued }

class _WelcomeScreenState extends State<WelcomeScreen> {
  //
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  String? _newVoiceText =
      "Welcome to Lucid eye, a number one digital assistant app for visually impaired individuals. Double tap the screen to start using the app or tap start button";
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

  final controller = PageController();
  bool isLastPage = false;
  String name = "Lucid Eye";

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _newVoiceText;
    });
    initTts();
    _speak();
    super.initState();
  }

  @override
  void dispose() async {
    controller.dispose();
    await _stop();
    await flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final PageController controller = PageController();
    return Scaffold(
        backgroundColor: mainColor,
        body: SafeArea(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NavigationBarScreen()),
              );
            },
            child: Container(
              width: width,
              child: Column(
                children: [
                  SizedBox(
                    height: height * 0.06,
                  ),
                  SizedBox(
                    width: width,
                    height: height * 0.65,
                    child: SizedBox(
                      child: PageView(
                          controller: controller,
                          onPageChanged: (index) {
                            setState(() => isLastPage = index == 2);
                          },
                          children: <Widget>[
                            buildPage(
                                pageWidth: width,
                                pageHeight: height,
                                color: Colors.white,
                                urlImage: "assets/specs.png",
                                title: "Mixed Reality",
                                titleDecsription:
                                    "Gives high resultion for both VR and AR when navigating"),
                            buildPage(
                                pageWidth: width,
                                pageHeight: height,
                                color: Colors.white,
                                urlImage: "assets/img1.png",
                                title: "Blind Assistance",
                                titleDecsription:
                                    "Helps visially impaired individuals to see the world around them through AI and AR"),
                            buildPage(
                                pageWidth: width,
                                pageHeight: height,
                                color: Colors.white,
                                urlImage: "assets/specsi.png",
                                title: "Object Detection ",
                                titleDecsription:
                                    "The software will allow users to take advantage of object detection AI and VOICE over")
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: GestureDetector(
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NavigationBarScreen()),
            );
          },
          child: Container(
            width: width,
            height: height * 0.2,
            color: mainColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        type: WormType.thin,
                        dotColor: white.withOpacity(0.5),
                        activeDotColor: primaryColor
                        // strokeWidth: 5,
                        ),
                    onDotClicked: (index) => controller.animateToPage(index,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeIn),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print("===================STARTED NAVIGATION=========");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationBarScreen()),
                    );
                    print("===================ENDED NAVIGATION=========");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shadowColor: greyd,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(width * 0.8, 50),
                  ),
                  child: const Text(
                    'Let\'s Start',
                    style: TextStyle(fontSize: 16, color: white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildPage(
          {required double pageWidth,
          required double pageHeight,
          required Color color,
          required String urlImage,
          required String title,
          required String titleDecsription}) =>
      Container(
        width: pageWidth,
        child: Center(
          child: Stack(
            children: [
              Container(
                width: pageWidth * 0.9,
                height: pageHeight * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Center(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: white.withOpacity(0.1),
                                  width: 1.0,
                                ),
                                color: white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: white.withOpacity(0.1),
                                          width: 1.0,
                                        ),
                                        color: white.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 5,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ]),
                                    padding: EdgeInsets.all(10),
                                    height: pageHeight * 0.65 * 0.6,
                                    width: pageHeight * 0.65 * 0.6,
                                    child: Image.asset(urlImage),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: pageWidth * 0.7,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: white),
                      ),
                    ),
                    Container(
                      width: pageWidth * 0.7,
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        titleDecsription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: white.withOpacity(0.6)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
