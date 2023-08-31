import 'package:flutter/material.dart';
import '../constants.dart';

class RequestsStatusList extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onStatusChanged;

  RequestsStatusList({
    required this.selectedIndex,
    required this.onStatusChanged,
  });

  @override
  State<RequestsStatusList> createState() => _RequestsStatusListState();
}

class _RequestsStatusListState extends State<RequestsStatusList> {
  final List<String> status = [
    'All',
    'Accepted',
    'Pending',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: MediaQuery.sizeOf(context).width - 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: status.length,
        itemBuilder: (context, index) {
          bool isSelected = (index == widget.selectedIndex);
          return GestureDetector(
            onTap: () {
              // Calling with the selected index
              widget.onStatusChanged(index); 
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? kBlueColor : kGreyColor500,
              ),
              child: Center(
                child: Text(
                  status[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? kWhiteColor : kBlackColor800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
