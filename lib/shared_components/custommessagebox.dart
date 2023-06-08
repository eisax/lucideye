import 'package:flutter/material.dart';
import 'package:lucideye/constants/colors.dart';

class CustomMessageInput extends StatefulWidget {
  final IconData startIcon;
  final IconData endIcon;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CustomMessageInput({
    Key? key,
    this.startIcon = Icons.person,
    this.endIcon = Icons.lock,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomMessageInput> createState() => _CustomMessageInputState();
}

class _CustomMessageInputState extends State<CustomMessageInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 2,
        //     blurRadius: 7,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      child: TextField(
       maxLines: null,
        controller: widget.controller,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: 12,decoration: TextDecoration.none),
        decoration: const InputDecoration(
          border: InputBorder.none,
          
          hintText: 'Type something...',
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          
        ),
      ),
    );
  }
}