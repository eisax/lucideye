import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucideye/config/navigations.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  NavigationBarScreen n = const NavigationBarScreen();
  final List<Map<String, dynamic>> messages = [
    {
      "message": "Hi",
      "time": "12:53",
      "type": "user",
    },
    {
      "message": "Hi, How are you doing",
      "time": "12:54",
      "type": "bot",
    },
    {
      "message": "I'm okay",
      "time": "12:55",
      "type": "user",
    },
    {
      "message": "good, how can I help you",
      "time": "12:55",
      "type": "bot",
    },
    {
      "message": "I need to know what time it is?",
      "time": "12:55",
      "type": "user",
    },
    {
      "message": "Oh great, the time is 15:17",
      "time": "12:57",
      "type": "bot",
    },
    {
      "message": "How else can you help",
      "time": "12:57",
      "type": "user",
    },
    {
      "message":
          "I am a Lucid your bot and I can help through giving you the info that you want, I can also help you know thngs and discuss",
      "time": "12:57",
      "type": "bot",
    }
  ];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        width: displayWidth,
        height: displayHeight,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: displayWidth,
              height: displayHeight * 0.15 > displayWidth * 0.2
                  ? displayHeight * 0.12
                  : displayWidth * 0.21,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: displayWidth * 0.1,
                    height: displayWidth * 0.1,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NavigationBarScreen(),
                            ),
                          );
                        });
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: displayWidth * 0.05,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayWidth * 0.2,
                    width: displayWidth * 0.6,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          child: Text('L'), // Use sender initials as avatar
                        ),
                        Container(
                          height: displayWidth * 0.1,
                          padding: EdgeInsets.only(left: displayWidth * 0.025),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Text(
                                'Lucid Chatbot',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: greyd,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Active Now',
                                style: TextStyle(
                                    fontSize: 8,
                                    color: greyc,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: displayWidth * 0.1,
                    height: displayWidth * 0.1,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.info_outline,
                        size: displayWidth * 0.05,
                      ),
                    ),
                  )
                ],
              ),
            ),

            //Message Box
            Expanded(
              child: Container(
                width: displayWidth,
                color: greya,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        width: displayWidth,
                        padding: const EdgeInsets.only(left:20,right:20,bottom: 5),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return Container(
                              width: displayWidth,
                              padding: const EdgeInsets.all(5),
                              child: message['type'] == "bot"
                                  ? botmessage(
                                      message: message['message'],
                                      time: message['time'],
                                      type: message['type'],
                                      displayWidth: displayWidth,
                                      displayHeight: displayHeight)
                                  : usermessage(
                                      message: message['message'],
                                      time: message['time'],
                                      type: message['type'],
                                      displayWidth: displayWidth,
                                      displayHeight: displayHeight),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: displayWidth,
                      padding: const EdgeInsets.all(10),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              width: displayWidth * 0.9,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ]),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        'Record Something....',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: greyc,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: greyd,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ]),
                                    child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.mic,
                                          size: 20,
                                          color: Colors.white,
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget botmessage(
      {required String message,
      required String time,
      required String type,
      required double displayWidth,
      required double displayHeight}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ]),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 15,
                  child: Text('L'),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: displayWidth * 0.6,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                            fontSize: 10,
                            color: greyc,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        time,
                        style: TextStyle(
                            fontSize: 8,
                            color: greyc,
                            fontWeight: FontWeight.w300),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget usermessage(
      {required String message,
      required String time,
      required String type,
      required double displayWidth,
      required double displayHeight}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: greyd,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ]),
              child: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: displayWidth * 0.7,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 10,
                            color: white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const  SizedBox(height: 5,),
                        Text(
                          time,
                          style: TextStyle(
                              fontSize: 8,
                              color: white,
                              fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
