import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucideye/constants/colors.dart';
class LocationWidget extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  LocationWidget({required this.color, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    
    return Container(
                    width: width * 0.8,
                    height: height * 0.12,
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.15,
                          height: height * 0.12,
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.location_on,
                                  size: height * 0.1,
                                  color: greyd,
                                ),
                              ),
                              Positioned(
                                  child: Container(
                                width: width * 0.5,
                                height: height * 0.12,
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: height * 0.028,
                                          left: height * 0.03),
                                      width: height * 0.04,
                                      height: height * 0.04,
                                      decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(
                                              height * 0.07)),
                                      child: Center(
                                        child: Text(
                                          '1',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: greyc,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                        Container(
                          width: width * 0.5,
                          height: height * 0.12,
                          padding: EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '400 A Causeway',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: greyd,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5,),
                              Text(
                                'Harare, Zimbabwe',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: greyc,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: 5,),
                              Text(
                                'My Location',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: greyb,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: width * 0.15,
                          height: height * 0.1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: height * 0.05,
                                height: height * 0.05,
                                decoration: BoxDecoration(
                                    color: greya,
                                    borderRadius: BorderRadius.circular(
                                        height * 0.07)),
                                child: IconButton(
                                    onPressed: () {
                                      //turnVolumeOn();
                                    },
                                    icon: Icon(
                                      Icons.done,
                                      size: 20,
                                      color: greyd,
                                    )),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(
                                        height * 0.07)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                  }
}