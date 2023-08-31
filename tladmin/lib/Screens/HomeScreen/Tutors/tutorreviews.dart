
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';

class TutorReviews extends StatefulWidget {
  static String routeName = 'TutorReviews';

  @override
  _TutorReviewsState createState() => _TutorReviewsState();
}

class _TutorReviewsState extends State<TutorReviews> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ReviewCard>> fetchReviewsData() async {
    List<ReviewCard> reviews = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('TutorReviews')
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        String tutorId = doc['tutorId'];

        // fetch tutor name based on tutorId
        String tutorName = await fetchTutorName(tutorId);

        // check if tutor name matches the search text
        if (_searchText.isEmpty ||
            tutorName.toLowerCase().contains(_searchText.toLowerCase())) {
          ReviewCard reviewCard = ReviewCard(
            tutorId: tutorId,
            postedBy: doc['postedBy'],
            message: doc['message'],
            timePosted: doc['timePosted'],
            userImage: doc['userImage'],
            rating: doc['rating'],
          );
          reviews.add(reviewCard);
        }
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }

    return reviews;
  }

  Future<String> fetchTutorName(String tutorId) async {
    try {
      DocumentSnapshot tutorSnapshot = await FirebaseFirestore.instance
          .collection('Tutors')
          .doc(tutorId)
          .get();

      if (tutorSnapshot.exists) {
        return tutorSnapshot.get('name');
      }
    } catch (e) {
      print('Error fetching tutor name: $e');
    }

    return 'Unknown Tutor';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by tutor name',
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchText = '';
                });
              },
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: FutureBuilder<List<ReviewCard>>(
            future: fetchReviewsData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error fetching reviews'),
                );
              } else {
                List<ReviewCard> reviews = snapshot.data ?? [];
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return reviews[index];
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }


}

class ReviewCard extends StatefulWidget {
  @override
  State<ReviewCard> createState() => _ReviewCardState();
  final String? courseId;
  final String postedBy;
  final String message;
  final Timestamp timePosted;
  final String userImage;
  final String? tutorId;
  final int rating;

  const ReviewCard({
    required this.postedBy,
    required this.message,
    required this.timePosted,
    required this.userImage,
    required this.rating,
    this.courseId,
    this.tutorId,
  });
}

class _ReviewCardState extends State<ReviewCard> {
  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  Future<String> fetchTutorName(String tutorId) async {
    try {
      DocumentSnapshot tutorSnapshot = await FirebaseFirestore.instance
          .collection('Tutors')
          .doc(tutorId)
          .get();

      if (tutorSnapshot.exists) {
        return tutorSnapshot.get('name');
      }
    } catch (e) {
      print('Error fetching tutor name: $e');
    }

    return 'Unknown Tutor';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      surfaceTintColor: kBlueColor,
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          height: 100,
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
                    FutureBuilder<String>(
                      future: fetchTutorName(widget.tutorId ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching tutor name');
                        } else {
                          String tutorName = snapshot.data ?? 'Unknown Tutor';
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: Text(
                                  tutorName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(formatDate(widget.timePosted))
                            ],
                          );
                        }
                      },
                    ),
                    Text(
                      '${widget.message}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(),
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: kYellowColor,
                        ),
                        Text(widget.rating.toStringAsFixed(1))
                      ],
                    )
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
