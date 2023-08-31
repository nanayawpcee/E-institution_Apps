import 'package:flutter/material.dart';
import '../constants.dart';


//customdropdown menu which consist of a list of departments for the app
class CustomDropdownButton extends StatelessWidget {
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  CustomDropdownButton({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: kGreyColor500,
        labelText: 'Select Department',
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
      value: value,
      items: items.map((department) {
        return DropdownMenuItem<String>(
          value: department,
          child: Text(department),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
