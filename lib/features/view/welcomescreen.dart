import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucideye/config/navigations.dart';
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
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.06,
              ),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Lucid ',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Eye',
                      style: const TextStyle(
                        fontSize: 21,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          //link to T & C
                        },
                    ),
                  ],
                ),
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
                          urlImage: "assets/img2.png",
                          title: "Help visiually impaired to navigate",
                        ),
                        buildPage(
                          pageWidth: width,
                          pageHeight: height,
                          color: Colors.white,
                          urlImage: "assets/img1.png",
                          title: "No more walking cane or a personal navigator",
                        ),
                        buildPage(
                          pageWidth: width,
                          pageHeight: height,
                          color: Colors.white,
                          urlImage: "assets/person.jpg",
                          title: "Find nearest help on emergencies ",
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          width: width,
          height: height * 0.25,
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
                      dotColor: Colors.grey.withOpacity(0.5),
                      activeDotColor: Colors.blueGrey
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
              MaterialPageRoute(builder: (context) => NavigationBarScreen()),
            );
            print("===================ENDED NAVIGATION=========");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shadowColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.8),
                  ),
                  minimumSize: Size(width * 0.8, 40),
                ),
                child: const Text(
                  'Let\'s Start',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Have an Account? ',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Log in',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          //link to T & C
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildPage({
    required double pageWidth,
    required double pageHeight,
    required Color color,
    required String urlImage,
    required String title,
  }) =>
      Container(
        width: pageWidth,
        child: Center(
          child: Stack(
            children: [
              Container(
                width: pageWidth * 0.9,
                height: pageHeight * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Center(
                        child: SizedBox(
                          height: pageHeight * 0.65 * 0.7,
                          child: Image.asset(urlImage),
                        ),
                      ),
                    ),
                    Container(
                      width: pageWidth * 0.7,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
