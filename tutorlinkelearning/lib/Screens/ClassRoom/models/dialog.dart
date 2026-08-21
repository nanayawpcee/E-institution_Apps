import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

Future<void> showMaterialDialog(BuildContext context, Function(List<File>) onSendFiles) async {
  bool isLoading = false;
  bool isFilesAdded = false;
  List<File> selectedFiles = [];

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickFiles() async {
            final files = await FilePicker.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
            );

            if (files.isNotEmpty) {
              setState(() {
                selectedFiles = files
                    .where((file) => file.path != null)
                    .map((file) => File(file.path!))
                    .toList();
                isFilesAdded = selectedFiles.isNotEmpty;
              });
            }
          }

          return AlertDialog(
            title: const Text('Add Material'),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Send material to students'),
                    const SizedBox(height: 16),
                    if (selectedFiles.isNotEmpty)
                      Column(
                        children: List.generate(
                          selectedFiles.length,
                          (index) => ListTile(
                            title: Text(
                              selectedFiles[index].path.split('/').last,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        await pickFiles();
                      },
                child: const Text('Add'),
              ),
              TextButton(
                onPressed: isLoading || !isFilesAdded
                    ? null
                    : () async {
                        if (selectedFiles.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });

                          await onSendFiles(selectedFiles);

                          setState(() {
                            isLoading = false;
                          });

                          Navigator.of(context).pop();
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Send'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}
