import 'package:flutter/material.dart';

import '../../../constants.dart';

//menu item design and callback to enhance user experience
Widget menuItem({required String title, bool isActive = false, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(right: 75),
      child: Column(
        children: [
          Text(
            '$title',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? kBlueColor : kGreyColor800,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          isActive
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: kBlueColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                )
              : const SizedBox()
        ],
      ),
    ),
  );
}
