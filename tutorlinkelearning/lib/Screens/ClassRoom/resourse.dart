import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Components/resourcemangement.dart';
import '../../utils/check_permission.dart';

class ResourcePage extends StatefulWidget {
  final String studentId;
 
  final String courseId;
  const ResourcePage({required this.studentId,  required this.courseId});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   bool isPermission = false;
  var checkAllPermissions = CheckPermission();

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources Screen'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('Classroom')
            .where('courseId', isEqualTo: widget.courseId)
            .where('studentId', isEqualTo: widget.studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No resources available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final resources = doc['resources'] as List<dynamic>;
              final timestamps = doc['timestamps'] as List<dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < resources.length; i++)
                    ResourceItem(
                      resourceTitle: resources[i]['title'],
                      resourceUrl: resources[i]['url'],
                      timestamp: timestamps[i]['time'].toDate(),
                       
                    ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
