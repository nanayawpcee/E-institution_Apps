import 'package:tutorlinkelearning/constants.dart';
import 'package:flutter/material.dart';

class OnboardContent {
  final String image, title, description;

  OnboardContent(
      {required this.image, required this.title, required this.description});
}

//onboard data with svgs
final List<OnboardContent> onboard_data = [
  OnboardContent(
      image: "assets/svgs/onboard0.svg",
      title: "Welcome to TutorLink",
      description:
          "Welcome as you learn  world changing skills to get a better job"),
  OnboardContent(
      image: "assets/svgs/onboard1.svg",
      title: "choose Your course",
      description:
          "Choose the course of your choice and gain knowledge and experience in it"),
  OnboardContent(
      image: "assets/svgs/onboard2.svg",
      title: "Get Certified",
      description:
          "Start learning and get certified after your training to get a lucrative job"),
];

class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: 8,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: isActive ? kPrimaryColor : kBlueColor),
    );
  }
}


