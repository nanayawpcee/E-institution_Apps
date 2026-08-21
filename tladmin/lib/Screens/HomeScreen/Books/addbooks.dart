import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_table.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';
import '../../../utils/csv_export.dart';
import '../Shell/admin_form.dart';

/// Route wrapper kept for the named-route table.
class AddBooksPage extends StatelessWidget {
  static String routeName = 'AddBooks';

  const AddBooksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const BooksBody();
}

class BooksBody extends ConsumerStatefulWidget {
  const BooksBody({Key? key}) : super(key: key);

  @override
  ConsumerState<BooksBody> createState() => _BooksBodyState();
}

class _BooksBodyState extends ConsumerState<BooksBody> {
  String _pickedName = '';
  Uint8List? _pickedBytes;
  int _pickedSize = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final books = ref.watch(adminDataProvider).bookFiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TLPageHeader(
          title: 'Books',
          subtitle: '${books.length} file${books.length == 1 ? '' : 's'}',
          trailing: TLSecondaryButton(
            label: 'Export CSV',
            icon: Icons.file_download_outlined,
            onPressed: () => CsvExport.copy(
              context,
              label: '${books.length} book${books.length == 1 ? '' : 's'}',
              headers: const ['File', 'Size', 'Uploaded'],
              rows: [
                for (final b in books)
                  [
                    b.name,
                    b.sizeLabel,
                    DateFormat('yyyy-MM-dd').format(b.uploadedAt),
                  ],
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.card,
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(TLTokens.rLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TLUploadZone(
                onTap: _pickFile,
                emptyIcon: Icons.upload_rounded,
                emptyLabel: 'Click to select a PDF',
                child: _pickedName.isEmpty
                    ? null
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 26,
                            color: TLTokens.danger,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _pickedName,
                            style: TLText.sub(t.text).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              TLPrimaryButton(
                label: 'Upload Book',
                onPressed: _pickedBytes == null ? null : _upload,
              ),
            ],
          ),
        ),
        TLTable(
          columns: const [
            TLColumn(label: 'File', flex: 2),
            TLColumn(label: 'Size', flex: 1),
            TLColumn(label: 'Uploaded', flex: 1),
            TLColumn(width: 80, alignment: Alignment.centerRight),
          ],
          emptyState: const TLEmptyState(
            icon: Icons.library_books_outlined,
            title: 'No books uploaded yet',
            message: 'Pick a PDF above to add it to the library.',
          ),
          rows: [
            for (final book in books)
              TLTableRow(
                cells: [
                  TLCell(book.name, strong: true),
                  TLCell(book.sizeLabel),
                  TLCell(DateFormat('d MMM y').format(book.uploadedAt)),
                  InkWell(
                    onTap: () => _remove(book.name),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Text(
                        'Remove',
                        style:
                            TLText.tag(TLTokens.danger).copyWith(fontSize: 12.5),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      dialogTitle: 'Select Book',
    );
    if (!mounted) return;

    if (result == null || result.files.isEmpty) {
      _toast('No file selected');
      return;
    }
    setState(() {
      _pickedName = result.files.first.name;
      _pickedBytes = result.files.single.bytes;
      _pickedSize = result.files.single.size;
    });
  }

  void _upload() {
    ref
        .read(adminDataProvider.notifier)
        .addBookFile(_pickedName, sizeBytes: _pickedSize);
    setState(() {
      _pickedName = '';
      _pickedBytes = null;
      _pickedSize = 0;
    });
    _toast('Book uploaded');
  }

  void _remove(String name) {
    ref.read(adminDataProvider.notifier).removeBookFile(name);
    _toast('$name removed');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
