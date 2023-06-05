import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import '../../constants/colors.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    return Container(
      width: displayWidth,
      height: displayHeight,
      color: white,
      padding: EdgeInsets.only(top: displayHeight * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // //this is the first bar with names and staff
          // Container(
          //   padding: EdgeInsets.all(5),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Container(
          //         width: displayWidth * 0.5,
          //         height: displayHeight * 0.1,
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //           children: [
          //             //image boox, insert image of the user
          //             Container(
          //               width: displayHeight * 0.04,
          //               height: displayHeight * 0.04,
          //               decoration: BoxDecoration(
          //                   color: Colors.grey,
          //                   borderRadius:
          //                       BorderRadius.circular(5)),
          //             ),
          //             Container(
          //               padding: EdgeInsets.all(5),
          //               height: displayHeight * 0.1,
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   FittedBox(
          //                     fit: BoxFit.contain,
          //                     child: Text(
          //                       "Hello Kudah",
          //                       style: TextStyle(
          //                         fontSize: displayHeight * 0.015,
          //                         color: greyc,
          //                       ),
          //                     ),
          //                   ),
          //                   SizedBox(height: 5),
          //                   FittedBox(
          //                     fit: BoxFit.contain,
          //                     child: Text(
          //                       "Complete Profile",
          //                       style: TextStyle(
          //                         fontSize: displayHeight * 0.015,
          //                         color: red,
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //       Container(
          //         width: displayWidth * 0.4,
          //         height: displayHeight * 0.1,
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //           children: [
          //             Container(
          //               padding: EdgeInsets.all(5),
          //               height: displayHeight * 0.1,
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   FittedBox(
          //                     fit: BoxFit.contain,
          //                     child: Text(
          //                       "CUT - main campus",
          //                       style: TextStyle(
          //                         fontSize: displayHeight * 0.015,
          //                         color: greyc,
          //                       ),
          //                     ),
          //                   ),
          //                   SizedBox(height: 5),
          //                   FittedBox(
          //                     fit: BoxFit.contain,
          //                     child: Text(
          //                       "See your location",
          //                       style: TextStyle(
          //                         fontSize: displayHeight * 0.015,
          //                         color: red,
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          //this is the second bar with heading and instructions
          Container(
            padding: EdgeInsets.all(25),
            child: Column(
              children: [
                Container(
                  width: displayWidth * 0.8,
                  child: Text(
                    "Emergency Help needed?",
                    style: TextStyle(
                      fontSize: displayWidth * 0.1,
                      color: greyd,
                      fontWeight: FontWeight.bold
                      
                    ),
                    textAlign: TextAlign.center,
                    
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  width: displayWidth * 0.8,
                  child: Text(
                    "Hold the button dowm or shake your phone",
                    style: TextStyle(
                      fontSize: displayHeight * 0.02,
                      color: greyb,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          //this is the third bar with start button
          Container(
            width: displayWidth * 0.8,
            height: displayHeight * 0.35,
            child: Stack(
              children: [
                Center(
                  child: ClayContainer(
                    color: white,
                    height: displayHeight * 0.28,
                    width: displayHeight * 0.28,
                    borderRadius: displayHeight * 0.28 * 0.5,
                    curveType: CurveType.concave,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            
                            height: displayHeight * 0.24,
                            width: displayHeight * 0.24,
                            decoration: BoxDecoration(
                              color: red,
                              borderRadius:BorderRadius.circular(displayHeight * 0.24*0.5)
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: ClayContainer(
                                    color: red,
                                    height: displayHeight * 0.21,
                                    width: displayHeight * 0.21,
                                    borderRadius: displayHeight * 0.24 * 0.5,
                                    curveType: CurveType.convex,
                                    child: Icon(Icons.sos_sharp,size: displayHeight * 0.05,color: white,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          //this is the fourth bar with someone coming to save the day
        ],
      ),
    );
  }
}
