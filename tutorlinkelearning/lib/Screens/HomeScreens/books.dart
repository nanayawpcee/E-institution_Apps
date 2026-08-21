import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/booksview.dart';
import '../../components/home.dart';
import '../../providers/student_data.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';

/// Books tab: the shared PDF library, searchable, each row opening the viewer.
class Books extends ConsumerStatefulWidget {
  const Books({Key? key}) : super(key: key);

  @override
  ConsumerState<Books> createState() => _BooksState();
}

class _BooksState extends ConsumerState<Books> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final books = ref.watch(studentDataProvider).bookFiles.where((b) {
      return _search.isEmpty || b.name.toLowerCase().contains(_search);
    }).toList();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, kTabBottomInset),
          children: [
            Text('Books', style: TLText.screenTitle(t.text)),
            const SizedBox(height: 16),
            TLSearchField(
              hint: 'Search books to read',
              controller: _searchController,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
            const SizedBox(height: 22),
            Text('Your library', style: TLText.cardTitle(t.text)),
            const SizedBox(height: 12),
            if (books.isEmpty)
              TLEmptyState(
                icon: Icons.menu_book_outlined,
                title: _search.isEmpty ? 'No books yet' : 'No matching books',
                message: _search.isEmpty
                    ? 'Books shared by your tutors will appear here.'
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
