import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thetutorlink/Screens/ClassRoom/coursematerialbucket.dart';
import 'package:thetutorlink/constants.dart';

class StudentsCard extends StatefulWidget {
  @override
  State<StudentsCard> createState() => _StudentsCardState();
  final String name;
  final String studentId;
  final String userImage;
  final String age;

  const StudentsCard({
    required this.studentId,
    required this.userImage,
    required this.name,
    required this.age,
  });
}

class _StudentsCardState extends State<StudentsCard> {
  final String tutorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseMaterialPage(
              tutorId: tutorId,
              studentId: widget.studentId,
            ),
          ),
        );
      },
      child: Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              color: Colors.transparent,
              height: 83,
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'userImage_${widget.studentId}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        width: 75,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: kBlueColor,
                            image: DecorationImage(
                                image: NetworkImage(widget.userImage),
                                fit: BoxFit.fill)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'name_${widget.studentId}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              widget.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
