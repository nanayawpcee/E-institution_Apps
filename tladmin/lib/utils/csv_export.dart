import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Renders rows as RFC-4180 CSV and puts them on the clipboard.
///
/// The design's "Export CSV" downloads a file; a Flutter console has no
/// portable download across desktop, web and mobile, so the export lands on
/// the clipboard and the caller confirms with a snackbar.
class CsvExport {
  const CsvExport._();

  static String encode(List<String> headers, List<List<String>> rows) {
    final buffer = StringBuffer()..writeln(headers.map(_field).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_field).join(','));
    }
    return buffer.toString();
  }

  static Future<void> copy(
    BuildContext context, {
    required List<String> headers,
    required List<List<String>> rows,
    required String label,
  }) async {
    await Clipboard.setData(ClipboardData(text: encode(headers, rows)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard as CSV')),
    );
  }

  static String _field(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }
}
