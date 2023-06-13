import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:lucideye/features/view/chatbotscreen.dart';
import 'package:lucideye/features/view/mapscreen.dart';
import 'package:lucideye/features/view/detectionscreen.dart';
import 'package:lucideye/features/view/emergencyscreen.dart';
import 'package:picovoice_flutter/picovoice_error.dart';
import 'package:picovoice_flutter/picovoice_manager.dart';
import 'package:rhino_flutter/rhino.dart';
import '../time_date_models/date.dart';
import '../time_date_models/time.dart';

class NavigationBarScreen extends StatefulWidget {
  
  const NavigationBarScreen({Key? key}) : super(key: key);
  

  @override
  _NavigationBarScreenState createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {

  //Picovoice accesskey
  String accessKey = 'msoa/qJ2l4nnbxf3cw/iu1xFPjSGDjom9j/8cjFpfmUWX5PHhlQROQ==';

  final FlutterTts _flutterTts = FlutterTts();

  bool isError = false;
  String errorMessage = "";
  bool listeningForCommand = false;
  PicovoiceManager? _picovoiceManager;



  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DetectionScreen(),
    MapScreen(),
    ChatbotScreen(),
    EmergencyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  void _initPicovoice() async {

    print("============================PICOVOICE HAS INITIALIZED SUCCESSFULLY===================================");

    String keywordAsset = "assets/picovoice_models/alexa_en_android_v2_2_0.ppn";
    String contextAsset = "assets/picovoice_models/Screen-Navigations_en_android_v2_2_0.rhn";

    try {
      _picovoiceManager = await PicovoiceManager.create(accessKey, keywordAsset, _wakeWordCallback, contextAsset, _inferenceCallback, processErrorCallback: _errorCallback);
      await _picovoiceManager?.start();
    } on PicovoiceInvalidArgumentException catch (ex) {
      _errorCallback(PicovoiceInvalidArgumentException(
          "${ex.message}\nEnsure your accessKey '$accessKey' is a valid access key."));
    } on PicovoiceActivationException {
      _errorCallback(
          PicovoiceActivationException("AccessKey activation error."));
    } on PicovoiceActivationLimitException {
      _errorCallback(PicovoiceActivationLimitException(
          "AccessKey reached its device limit."));
    } on PicovoiceActivationRefusedException {
      _errorCallback(PicovoiceActivationRefusedException("AccessKey refused."));
    } on PicovoiceActivationThrottledException {
      _errorCallback(PicovoiceActivationThrottledException(
          "AccessKey has been throttled."));
    } on PicovoiceException catch (ex) {
      _errorCallback(ex);
    }
  }

  void _wakeWordCallback() {
    setState(() {
      listeningForCommand = true;
    });
  }

  void _inferenceCallback(RhinoInference inference) {
    print("============= RHINO INFERENCE: ${inference.toString()}===================");
    if (inference.isUnderstood!) {
      Map<String, String> slots = inference.slots!;
      if (inference.intent == 'objectdetector') {
        print("============= NAVIGATING TO DETECTION SCREEN===================");
        setState(() {
          _onItemTapped(0);
        });
      } else if (inference.intent == 'map_screen') {
        print("============= NAVIGATING TO MAP SCREEN===================");
        setState(() {
          _onItemTapped(1);
        });
      }else if (inference.intent == 'chatscreen') {
        print("============= NAVIGATING TO CHAT SCREEN===================");
        setState(() {
          _onItemTapped(2);
        });
      }else if (inference.intent == 'help') {
        print("============= NAVIGATING TO SOS SCREEN===================");
        setState(() {
          _onItemTapped(3);
        });
      }
      }else if (inference.intent == 'date') {
        print("============= DATE FOUND AND SAID SUCCESSFULLY===================");
        setState(() {
          GetDate().speakDate();
        });
      }else if (inference.intent == 'tommorrow') {
      print("============= TOMORROW DATE FOUND AND SAID SUCCESSFULLY===================");
        setState(() {
          GetDate().speakTomorrowDate();
        });
      }else if (inference.intent == 'time') {
      print("============= TIME FOUND AND SAID SUCCESSFULLY===================");
        setState(() {
          TimerTime().timer();
        });
      } else if (inference.intent == 'availableCommands') {
        String availableCommands = "I am just a prototype, for a blind assistant and object detection app'\n - 'You'll get full features once my development is done'\n - 'For now just navigate between screens by saying Navigate to:, then mention the screen you want to go to'";
        _flutterTts.speak(availableCommands);
      } else {
      String commandNotUnderstood = "I didn't understand your command! Please try again or go to help screen";
      _flutterTts.speak(commandNotUnderstood);
    }
    setState(() {
      listeningForCommand = false;
    });
  }

  void _errorCallback(PicovoiceException error) {
    setState(() {
      isError = true;
      errorMessage = error.message!;
      String errorMessageTTs;
      if(isError == true)
      {
        errorMessageTTs = errorMessage;
        _flutterTts.speak(errorMessageTTs);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initPicovoice();
  }


  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar:_selectedIndex==2?null: Container(
        margin: EdgeInsets.only(left:displayWidth * .1,bottom:displayWidth * .05,right:displayWidth * .1),
        child: Stack(
          children: [
            Container(
              height: displayWidth * .14,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(displayWidth * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildBottomNavItem(0, Icons.qr_code_scanner, context),
                  buildBottomNavItem(1, Icons.navigation_outlined, context),
                  buildBottomNavItem(2, Icons.chat_bubble_outline, context),
                  
                  buildBottomNavItem(3, Icons.sos_outlined, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavItem(int index, IconData icon, BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: displayWidth * .05,
            color: _selectedIndex == index ? mainColor : mainColor.withOpacity(0.5),
          ),
          SizedBox(height: displayWidth * .015),
        ],
      ),
    );
  }
}
