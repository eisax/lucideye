import 'package:flutter/material.dart';
import 'package:lucideye/constants/colors.dart';

class CustomTextInput extends StatelessWidget {
  final IconData startIcon;
  final IconData endIcon;

  const CustomTextInput({
    Key? key,
    this.startIcon = Icons.person,
    this.endIcon = Icons.lock,
  }) : super(key: key);

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
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: 13,decoration: TextDecoration.none),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(startIcon,size: 15,),
          suffixIcon: Icon(endIcon,size: 15,),
          hintText: 'Enter text...',
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }
}