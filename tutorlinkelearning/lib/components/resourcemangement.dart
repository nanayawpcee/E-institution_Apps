
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import '../constants.dart';
import 'booksview.dart';

class ResourceItem extends StatelessWidget {
  final String resourceTitle;
  final String resourceUrl;
  final DateTime timestamp; 

  ResourceItem({
    required this.resourceTitle,
    required this.resourceUrl,
    required this.timestamp,
  });


//this is for the date format on the resource card
  String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

   void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _downloadResource(BuildContext context) async {

    FileDownloader.downloadFile(
      url: resourceUrl,
      name: resourceTitle,
      onDownloadCompleted: (String filePath) {
          _showSnackBar(context, 'Download complete: $resourceTitle');
      },
      onDownloadError: (String error) {
        
        _showSnackBar(context, 'Download failed: $resourceTitle');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        tileColor: kGreyColor600,
        leading: Icon(Icons.insert_drive_file),
        iconColor: kBlueColor,
        title: Text(resourceTitle),
        subtitle: Text(formatDate(timestamp)),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Download'),
                    onTap: () {
                      Navigator.pop(context);
                      _downloadResource(context); 
                    },
                  ),
                ],
              );
            },
          );
        },
        onTap: () {
          Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(resourceUrl, resourceTitle),
        ),
      );
        },
      ),
    );
  }
}