import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucideye/config/navigations.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final controller = PageController();
  bool isLastPage = false;
  String name = "Lucid Eye";
  @override
  void dispose() {
    controller.dispose();
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
        bottomSheet: Container(
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
                      activeDotColor: white
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
                  backgroundColor: white,
                  shadowColor: greyd,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: Size(width * 0.8, 50),
                ),
                child: const Text(
                  'Let\'s Start',
                  style: TextStyle(fontSize: 16, color: mainColor),
                ),
              ),
            ],
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
                                  color: white,
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
                                          color: white,
                                          width: 1.0,
                                        ),
                                        color: white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 10,
                                            blurRadius: 10,
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
