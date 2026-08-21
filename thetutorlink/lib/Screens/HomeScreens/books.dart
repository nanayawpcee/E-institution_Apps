import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Components/booksview.dart';
import '../../Components/home.dart';
import '../../providers/tutor_data.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Books tab: the shared PDF library, searchable, with an add affordance for
/// the tutor's own uploads.
class Books extends ConsumerStatefulWidget {
  const Books({Key? key}) : super(key: key);

  @override
  ConsumerState<Books> createState() => _BooksState();
}

class _BooksState extends ConsumerState<Books> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final books = ref.watch(tutorDataProvider).bookFiles.where((b) {
      return _search.isEmpty || b.name.toLowerCase().contains(_search);
    }).toList();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, kTabBottomInset),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Read Books', style: TLText.screenTitle(t.text)),
                ),
                TLIconButton(icon: Icons.add_rounded, onPressed: _addBook),
              ],
            ),
            const SizedBox(height: 16),
            TLSearchField(
              hint: 'Search books to read',
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
            const SizedBox(height: 22),
            Text('Library', style: TLText.cardTitle(t.text)),
            const SizedBox(height: 12),
            if (books.isEmpty)
              TLEmptyState(
                icon: Icons.menu_book_outlined,
                title: _search.isEmpty ? 'No books yet' : 'No matching books',
                message: _search.isEmpty
                    ? 'Add a PDF with the button above.'
                    : 'Try a different title.',
              )
            else
              for (final book in books)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BookRow(
                    title: book.name,
                    onRead: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PdfViewerScreen(book.url, book.name),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBook() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      dialogTitle: 'Select a book',
    );
    if (!mounted) return;

    if (picked.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return;
    }

    final file = picked.single;
    final path = file.path;
    if (path == null) return;

    // Files stay as on-device paths; there is no Storage bucket to upload to.
    ref.read(tutorDataProvider.notifier).addBookFile(file.name, File(path).path);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${file.name} added')));
  }
}

/// Library row: spine-shaped cover mark, title, and a Read affordance.
class _BookRow extends StatelessWidget {
  const _BookRow({required this.title, required this.onRead});

  final String title;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return TLCard(
      onTap: onRead,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 56,
            decoration: BoxDecoration(
              color: TLTokens.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TLText.cardTitle(t.text).copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: t.cardAlt,
            borderRadius: BorderRadius.circular(TLTokens.rMd),
            child: InkWell(
              onTap: onRead,
              borderRadius: BorderRadius.circular(TLTokens.rMd),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'Read',
                  style: TLText.cardTitle(TLTokens.primary)
                      .copyWith(fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
