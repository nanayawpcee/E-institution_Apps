import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/constants.dart';

class DepartmentsList extends StatefulWidget {
  final Function(String) onDepartmentSelected;

  DepartmentsList({required this.onDepartmentSelected});

  @override
  State<DepartmentsList> createState() => _DepartmentsListState();
}

class _DepartmentsListState extends State<DepartmentsList> {
  //array containing a list of departments 
  //this is for the dashboarb page
  final List<String> departments = [
    'All',
    'Design',
    'Programming',
    'UI/UX',
    'Mathematics',
    'Biology',
    'Chemistry'
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: MediaQuery.of(context).size.width - 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        itemBuilder: (context, index) {
          bool isSelected = (index == selectedIndex);
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              String selectedDepartment = departments[index];
              widget.onDepartmentSelected(selectedDepartment);
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? kBlueColor : kGreyColor500),
              child: Center(
                child: Text(
                  departments[index],
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
