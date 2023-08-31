import 'package:flutter/material.dart';

import '../constants.dart';

class registerButton extends StatelessWidget {
  final VoidCallback onTap; //call back method 

  registerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: kGreyColor500, spreadRadius: 10, blurRadius: 12),
          ],
        ),
        child: const Text(
          "Register",
          style: TextStyle(fontWeight: FontWeight.bold, color: kBlackColor800),
        ),
      ),
    );
  }
}






