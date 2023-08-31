import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class ReviewCard extends StatefulWidget {
  @override
  State<ReviewCard> createState() => _ReviewCardState();
  final String? courseId;
  final String postedBy;
  final String message;
  final Timestamp timePosted;
  final String userImage;
  final String? tutorId;

  const ReviewCard(
      {required this.postedBy,
      required this.message,
      required this.timePosted,
      required this.userImage,
      this.courseId,
      this.tutorId});
}

class _ReviewCardState extends State<ReviewCard> {
  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      surfaceTintColor: kBlueColor,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          height: 80,
          width: MediaQuery.of(context).size.width - 32,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBlueColor,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                      widget.userImage,
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.postedBy,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(formatDate(widget.timePosted))
                      ],
                    ),
                    Text(
                      '${widget.message}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        letterSpacing: 0.5,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
