import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/TutorDetails/tutordetails.dart';
import 'package:tutorlinkelearning/constants.dart';

class TutorCard extends StatefulWidget {
  final String tutorId;
  final String imageUrl;
  final String tutorName;
  final String courseId;
  final int students;
  final int rating;
  final bool isOpen;

  TutorCard({
    required this.tutorId,
    required this.imageUrl,
    required this.courseId,
    required this.tutorName,
    required this.students,
    required this.rating,
    required this.isOpen,
  });

  @override
  State<TutorCard> createState() => _TutorCardState();
}

class _TutorCardState extends State<TutorCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TutorDetailScreen(
                      tutorId: widget.tutorId,
                      courseId: widget.courseId,
                    )));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBlueColor,
                  image: widget.imageUrl.isNotEmpty
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.imageUrl),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tutorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.students} Std(s)',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Icon(
                          Icons.star,
                          color: kYellowColor,
                        ),
                        Text('${widget.rating}.0')
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
