import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tutorlinkelearning/constants.dart';

class InteractionPage extends StatefulWidget {
  final String name;
  final String tutorId;
  final String studentId;

  const InteractionPage({
    required this.name,
    required this.tutorId,
    required this.studentId,
  });

  @override
  _InteractionPageState createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child('chats')
                  .child(widget.tutorId)
                  .child(widget.studentId)
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final chatData = snapshot.data!.snapshot.value;
                  if (chatData != null) {
                    final messages =
                        chatData is Map ? chatData.values.toList() : [];
                    messages.sort((a, b) => b['time']
                        .compareTo(a['time'])); // Sort in descending order

                    return ListView.builder(
                      reverse: true, // Reverse the list view
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index]['message'];
                        final timeMillis = messages[index]['time'];
                        final senderId = messages[index]['sender'];
                        final isTutorMessage = senderId == widget.tutorId;
                        final time =
                            DateTime.fromMillisecondsSinceEpoch(timeMillis);
                        final formattedTime =
                            DateFormat('EEE, MMM d, y, HH:mm').format(time);

                        return Row(
                          mainAxisAlignment: isTutorMessage//to ensure proper alignment and to distinguisg between the tutor message or the otherwise
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width / 2.3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isTutorMessage ? kGreyColor900 : kBlueColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: isTutorMessage// this is to align messages from bottom to app to allow easy readabilty
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    message,//display the message
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedTime,// this shows the formatted time under the message body for every message sent
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Show a loading indicator or empty message in our case we prefer a text
                    return const Center(child: Text('Wait! Getting Messages'));
                  }
                } else {
                  // Show a loading indicator or empty message in our case we prefer a Text
                  return const  Center(child: Text('Wait! Getting Messages'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _sendMessage();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && currentUser != null) {
      final senderId = currentUser!.uid;
      final timestamp = DateTime.now()
          .millisecondsSinceEpoch; // Convert Timestamp to milliseconds
      FirebaseDatabase.instance
          .ref()
          .child('chats')
          .child(widget.tutorId)
          .child(widget.studentId)
          .push()
          .set({
        'message': message,
        'time': timestamp, // Store timestamp as milliseconds
        'sender': senderId,
      }).then((_) {
        _messageController.clear();
      }).catchError((error) {
        //we are checking for errors in the console will work on this later
        print('Error sending message: $error');
      });
    }
  }
}
