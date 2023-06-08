import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucideye/config/navigations.dart';
import 'package:lucideye/constants/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:lucideye/shared_components/custommessagebox.dart';
import 'package:lucideye/shared_components/searchbar.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController _chatbotcontroller = TextEditingController();
  NavigationBarScreen n = const NavigationBarScreen();
  late String query = "";

  final List<Map<String, dynamic>> messages = [
    {
      "message": "Hi",
      "time": "12:53",
      "type": "bot",
    }
  ];
  //sending message fn api
  void sendMessage(String message) async {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    //typed message
    Map<String, dynamic> newMessage = {
      "message": message,
      "time": formattedTime,
      "type": "user",
    };
    //add typed message to list
    setState(() {
      messages.add(newMessage);
      _chatbotcontroller.clear();
      query;
    });
    onScrollChatToEnd();
    //prepare to send message to backend
    final requestData = {"message": message};

    //send message to backend
    final response = await http.post(
      Uri.parse('http://192.168.100.21:5000/talktome'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );
    //check if there is no error
    if (response.statusCode == 200) {
      //get response body
      final jsonResponse = jsonDecode(response.body);
      final messageResponse = jsonResponse['message'];
      //get response message and add it to list
      setState(() {
        messages.add(jsonResponse);
        _chatbotcontroller.clear();
        query;
      });
      onScrollChatToEnd();

      print(messages);
    } else {
      setState(() {
        messages.removeLast();
        _chatbotcontroller.text = message;
      });
      onScrollChatToEnd();
      // handle error if it is there
      print("Failed to send message. Error code: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void onScrollChatToEnd() {
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
                        color: greyc,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: displayWidth * 0.2,
                    width: displayWidth * 0.6,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: greyc,
                          foregroundColor: white,
                          child: Text('M'), // Use sender initials as avatar
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
                                    color: greyc,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Active Now',
                                style: TextStyle(
                                    fontSize: 8,
                                    color: greyd,
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
                        Icons.notifications,
                        size: displayWidth * 0.05,
                        color: greyc,
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
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 5),
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
                      padding: const EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              width: displayWidth,
                              decoration: BoxDecoration(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: displayWidth * 0.7,
                                    child: CustomMessageInput(
                                        controller: _chatbotcontroller,
                                        onChanged: (value) async {
                                          if (value.isNotEmpty) {
                                            print('Searching for: $value');

                                            setState(() {
                                              query = _chatbotcontroller.text;
                                              _chatbotcontroller;
                                            });
                                          }
                                        }),
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
                                        onPressed: () {
                                          if (_chatbotcontroller.text.isNotEmpty) {
                                            sendMessage(query);
                                          }
                                        },
                                        icon: Icon(
                                          _chatbotcontroller.text.isNotEmpty
                                              ? Icons.send
                                              : Icons.mic,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: greyc,
                  foregroundColor: white,
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
                      const SizedBox(
                        height: 5,
                      ),
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
                        const SizedBox(
                          height: 5,
                        ),
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
