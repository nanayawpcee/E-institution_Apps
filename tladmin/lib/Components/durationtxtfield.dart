import 'package:flutter/material.dart';

class DurationInputWidget extends StatefulWidget {
  final Function(double) onDurationUpdated; // Callback function to notify the parent widget

  DurationInputWidget({required this.onDurationUpdated});

  @override
  _DurationInputWidgetState createState() => _DurationInputWidgetState();
}

//a duration handler to get the duration of the courses
// we calculate the duration by converting every input which is days, hour, minutes - hours and push to the Api
class _DurationInputWidgetState extends State<DurationInputWidget> {
  int days = 0;
  int hours = 0;
  int minutes = 0;

  double _calculateDuration() {
    return days * 24 + hours + minutes / 60;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 1,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    days = int.tryParse(value) ?? 0;
                    widget.onDurationUpdated(_calculateDuration());
                  });
                },
                decoration: InputDecoration(labelText: 'Days'),
              ),
            ),
            Flexible(
              flex: 1,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    hours = int.tryParse(value) ?? 0;
                     widget.onDurationUpdated(_calculateDuration());
                  });
                },
                decoration: InputDecoration(labelText: 'Hours'),
              ),
            ),
            Flexible(
              flex: 1,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    minutes = int.tryParse(value) ?? 0;
                     widget.onDurationUpdated(_calculateDuration());
                  });
                },
                decoration: InputDecoration(labelText: 'Minutes'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Total Duration: ${days}d ${hours}h ${minutes}m',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
