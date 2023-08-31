// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../constants.dart';


//Custom text input field used for most part of this app
class InputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController textEditingController;
  int length;
  int lines;
  int minlines;
  final String CounterText;

  InputField(
      {required this.hintText,
      required this.icon,
      required this.textEditingController,
      this.length = 20,
      this.minlines= 1,
      this.CounterText = '',
      this.lines = 1});
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: length,
      minLines: minlines,
      maxLines: lines,
      cursorColor: kBlueColor,
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        prefixIcon: Icon(icon),
        fillColor: kGreyColor500,
        filled: true,
        labelStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.only(left: 30),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kBlueColor),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kBlueColor),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
