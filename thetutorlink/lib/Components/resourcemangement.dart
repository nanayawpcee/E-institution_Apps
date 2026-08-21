import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/tutor_data.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';
import 'booksview.dart';

/// A classroom file — resource or assignment. Tap opens the viewer; the
/// overflow offers download and, for resources the tutor owns, removal.
class ResourceItem extends ConsumerWidget {
  const ResourceItem({
    Key? key,
    required this.tutorId,
    required this.tutorDocumentId,
    required this.resourceTitle,
    required this.resourceUrl,
    required this.timestamp,
    this.canRemove = true,
  }) : super(key: key);

  final String tutorId;

  /// The classroom this file belongs to.
  final String tutorDocumentId;
  final String resourceTitle;
  final String resourceUrl;
  final DateTime timestamp;
  final bool canRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded, size: 20, color: t.textSub),
            onSelected: (value) {
              if (value == 'download') {
                _download(context);
              } else if (value == 'remove') {
                ref
                    .read(tutorDataProvider.notifier)
                    .removeResource(tutorDocumentId, resourceUrl);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'download', child: Text('Download')),
              if (canRemove)
                const PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
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
