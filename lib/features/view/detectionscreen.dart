import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:lucideye/features/view/detectionscreens/cameraoverlay.dart';

import 'detectionscreens/detectionscreen_a.dart';
import 'detectionscreens/detectionscreen_b.dart';
import 'detectionscreens/detectionscreen_c.dart';

class DetectionScreen extends StatelessWidget {
  
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical, // Set scroll direction to vertical
        children: [
          // DetectionScreen_a(),
          DetectionScreen_b(),
          DetectionScreen_c(),
          
        ],
      ),
    );
  }
}




