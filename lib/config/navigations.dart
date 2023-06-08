import 'package:flutter/material.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:lucideye/features/view/chatbotscreen.dart';
import 'package:lucideye/features/view/mapscreen.dart';
import 'package:lucideye/features/view/detectionscreen.dart';
import 'package:lucideye/features/view/emergencyscreen.dart';

class NavigationBarScreen extends StatefulWidget {
  
  const NavigationBarScreen({Key? key}) : super(key: key);
  

  @override
  _NavigationBarScreenState createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {
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
