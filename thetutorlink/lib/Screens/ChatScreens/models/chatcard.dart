import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thetutorlink/constants.dart';

import '../interactionpage.dart';

class ChatCard extends StatefulWidget {
  @override
  State<ChatCard> createState() => _ChatCardState();
  final String name;
  final String studentId;
  final String userImage;

  const ChatCard({
    required this.studentId,
    required this.userImage,
    required this.name,
  });
}

class _ChatCardState extends State<ChatCard> {
  final String tutorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InteractionPage(
              name: widget.name,
              tutorId: tutorId,
              studentId: widget.studentId,
            ),
          ),
        );
      },
      child: Card(
        shadowColor: kBlueColor,
        surfaceTintColor: kBlueColor,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            height: 75,
            width: MediaQuery.of(context).size.width - 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
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
                const SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
