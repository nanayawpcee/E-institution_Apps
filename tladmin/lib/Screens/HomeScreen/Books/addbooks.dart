import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';

import '../../../constants.dart';

class AddBooksPage extends StatefulWidget {
  static String routeName = 'AddBooks';

  @override
  _AddBooksPageState createState() => _AddBooksPageState();
}

class _AddBooksPageState extends State<AddBooksPage> {
  List<String> _bookFiles = [];
  String selectedFileName = ''; 
  Uint8List? selectedFileBytes;

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      dialogTitle: 'Select Book',
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFileName = result.files.first.name;
        selectedFileBytes = result.files.single.bytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  Future<void> _uploadFileToStorage() async {
    if (selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
      return;
    }

    String fileName = selectedFileName;
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('books')
        .child(fileName);

    await ref.putData(selectedFileBytes!); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File uploaded successfully')),
    );

    await _updateBookFilesList();
  }

  Future<void> _updateBookFilesList() async {
    firebase_storage.ListResult listResult =
        await firebase_storage.FirebaseStorage.instance.ref('books').list();

    List<String> files = listResult.items.map((item) => item.name).toList();

    setState(() {
      _bookFiles = files;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    _updateBookFilesList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 15),
      child: Container(
        color: kGreyColor500,
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 100,
                    child: Column(
                      children: [
                        Text(
                          selectedFileName,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                          ),
                        ), // to show selected file name
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: Text('Pick a Book'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: _uploadFileToStorage,
                          child: Text('Upload Book'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _bookFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_bookFiles[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
