import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thetutorlink/Components/requestcard.dart';
import 'package:http/http.dart' as http;

class StudentsRequestsList extends StatelessWidget {
  final String tutorId;
  final int selectedStatus;
  final String searchQuery;

  StudentsRequestsList({
    required this.tutorId,
    required this.selectedStatus,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Requests')
          .where('tutorId', isEqualTo: tutorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error fetching requests');
        }

        final requests = snapshot.data?.docs ?? [];

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request =
                requests[index] as QueryDocumentSnapshot<Map<String, dynamic>>;

            if (!request.exists) {
              return SizedBox.shrink(); // Skip invalid requests
            }

            final bool isAccepted = request['isAccepted'] as bool;
            final bool isRejected = request['isRejected'] as bool;
            final bool isPending = request['isPending'] as bool;

            bool shouldDisplay = false;

            // Filter based on selected status and search query
            if (selectedStatus == 0) {
              shouldDisplay = true;
            } else if (selectedStatus == 1 && isAccepted) {
              shouldDisplay = true;
            } else if (selectedStatus == 2 && isPending) {
              shouldDisplay = true;
            } else if (selectedStatus == 3 && isRejected) {
              shouldDisplay = true;
            }

            if (shouldDisplay) {
              final studentId = request['studentId'] as String?;

              if (studentId != null) {
                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('Students')
                      .doc(studentId)
                      .get(),
                  builder: (context, studentSnapshot) {
                    if (studentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (studentSnapshot.hasError) {
                      return Text('Error fetching student data');
                    }

                    final studentData = studentSnapshot.data?.data();

                    if (studentData != null) {
                      final studentName = studentData['name'] as String;

                      if (searchQuery.isEmpty ||
                          studentName
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase())) {
                        return RequestCard(
                          studentName: studentName,
                          studentImageUrl: studentData['userImage'] ??
                              SvgPicture.asset('assets/icons/avatar.svg'),
                          status: selectedStatus,
                          requestId: request.id,
                          onAccept: () =>
                              updateRequestStatus(request.id, true, false),
                          onReject: () =>
                              updateRequestStatus(request.id, false, true),
                          studentId: studentId,
                        );
                      }
                    }

                    return SizedBox.shrink();
                  },
                );
              }
            }

            return SizedBox.shrink();
          },
        );
      },
    );
  }

  Future<void> updateRequestStatus(
      String requestId, bool isAccepted, bool isRejected) async {
    try {
      // Get the FCM token of the student from Firestore
      final requestSnapshot = await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .get();
      final courseId = requestSnapshot['courseId'] as String?;
      final courseDoc = await FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseId)
          .get();

      final courseName = courseDoc['courseName'] as String?;

      final studentId = requestSnapshot['studentId'] as String?;
      final studentDocument = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .get();
      final stdFcmToken = studentDocument['fcmToken'] as String?;

      // Update request status
      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .update({
        'isPending': false,
        'isAccepted': isAccepted,
        'isRejected': isRejected,
      });

      // Send notification to the student if request is accepted
      if (isAccepted && stdFcmToken != null) {
        await sendNotificationToStudent(stdFcmToken, courseName!);
      }
    } catch (error) {
      print('Error updating request status: $error');
    }
  }

  final String fcmServerKey =
      'AAAAjRMB0Ac:APA91bGE970mDcSRHT6lUv-wyaw1Ao1DFUhKSzIaiMUc3uGsUPfErYi4-we9GztgQ-Vj6lDX5NVT662WmW67pf_sTslzf2S8eFqSES87enSqYCGE8mgDipCAj2oFb7kWTN1jx4OYEbnh';

  Future<void> sendNotificationToStudent(
      String name, String stdFcmToken) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$fcmServerKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': name,
              'title': 'Request Accepted',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': stdFcmToken,
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
}
