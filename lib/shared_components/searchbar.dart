import 'package:flutter/material.dart';
import 'package:lucideye/constants/colors.dart';

class CustomTextInput extends StatefulWidget {
  final IconData startIcon;
  final IconData endIcon;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CustomTextInput({
    Key? key,
    this.startIcon = Icons.person,
    this.endIcon = Icons.lock,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextInput> createState() => _CustomTextInputState();
}

class _CustomTextInputState extends State<CustomTextInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(

        controller: widget.controller,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 13,decoration: TextDecoration.none,color: mainColor,),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(widget.startIcon,size: 18,color: greyb,),
          suffixIcon: Icon(widget.endIcon,size: 25,color: mainColor,),
          hintText: 'Search location...',
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }
}