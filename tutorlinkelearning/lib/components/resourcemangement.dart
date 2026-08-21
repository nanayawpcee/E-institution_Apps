import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:intl/intl.dart';

import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';
import 'booksview.dart';

/// A classroom file — resource or assignment. Tap opens the viewer, long-press
/// offers a download.
class ResourceItem extends StatelessWidget {
  const ResourceItem({
    Key? key,
    required this.resourceTitle,
    required this.resourceUrl,
    required this.timestamp,
  }) : super(key: key);

  final String resourceTitle;
  final String resourceUrl;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLCard(
      padding: const EdgeInsets.all(12),
      radius: 14,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(resourceUrl, resourceTitle),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.cardAlt,
              borderRadius: BorderRadius.circular(TLTokens.rSm),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              size: 19,
              color: TLTokens.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resourceTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.cardTitle(t.text).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('d MMM y').format(timestamp),
                  style: TLText.meta(t.textSub),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Download',
            onPressed: () => _download(context),
            icon: Icon(Icons.download_rounded, size: 19, color: t.textSub),
          ),
        ],
      ),
    );
  }

  void _download(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    FileDownloader.downloadFile(
      url: resourceUrl,
      name: resourceTitle,
      onDownloadCompleted: (_) => messenger.showSnackBar(
        SnackBar(content: Text('Download complete: $resourceTitle')),
      ),
      onDownloadError: (_) => messenger.showSnackBar(
        SnackBar(content: Text('Download failed: $resourceTitle')),
      ),
    );
  }
}
