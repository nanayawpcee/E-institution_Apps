import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/ChatRoom/chatpage.dart';
import 'package:tutorlinkelearning/constants.dart';

class TutorChatCard extends StatefulWidget {
  final String tutorId;
  final String imageUrl;
  final String tutorName;
  final String courseId;
  final int students;
  final int rating;
  final bool isOpen;

  TutorChatCard({
    required this.tutorId,
    required this.imageUrl,
    required this.courseId,
    required this.tutorName,
    required this.students,
    required this.rating,
    required this.isOpen,
  });

  @override
  State<TutorChatCard> createState() => _TutorChatCardState();
}

class _TutorChatCardState extends State<TutorChatCard> {
  final studentId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InteractionPage(
                      tutorId: widget.tutorId,
                      studentId: studentId,
                      name: widget.tutorName,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people),
                        const SizedBox(width: 4),
                        Text('${widget.students} Std(s)'),
                        const SizedBox(width: 8),
                        Text(
                          widget.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Icon(
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
