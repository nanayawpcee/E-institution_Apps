import 'package:tutorlinkelearning/constants.dart';
import 'package:flutter/material.dart';

class CourseStatusList extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  CourseStatusList({
    required this.selectedIndex,
    required this.onChanged,
  });

  static final List<String> status = [
    'All',
    'Active',
    'Pending',
    'Completed',
  ];

 
    @override
    Widget build(BuildContext context) {
      return SizedBox(
        height: 40,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          itemCount: status.length,
          itemBuilder: (context, index) {
            bool isSelected = (index == selectedIndex);
            return GestureDetector(
              onTap: () {
                onChanged(index);
                // Implement filtering based on status here
                // Fetch the courses for the selected status
              },
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? kBlueColor : kGreyColor500),
                child: Center(
                  child: Text(
                    status[index],
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? kWhiteColor : kBlackColor800),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
