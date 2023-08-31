import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thetutorlink/Components/booksview.dart';
import 'package:thetutorlink/constants.dart';

class Books extends StatefulWidget {
  const Books({super.key});

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  final TextEditingController _booksearchController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Reference> _pdfFiles = [];
  List<Reference> _filteredPdfFiles = []; // Filtered PDF files list

  @override
  void initState() {
    super.initState();
    fetchPDFFiles();
  }

  Future<void> fetchPDFFiles() async {
    try {
      final Reference booksFolder = _storage.ref().child('books');
      final ListResult result = await booksFolder.listAll();

      setState(() {
        _pdfFiles = result.items;
        _filteredPdfFiles = _pdfFiles;
      });
    } catch (error) {
      print('Error fetching PDF files: $error');
    }
  }

  void _openPdfViewer(Reference pdfReference, String pdfFileName) async {
    try {
      String pdfUrl = await pdfReference.getDownloadURL();
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfUrl, pdfFileName),
        ),
      );
    } catch (error) {
      print('Error getting PDF URL: $error');
    }
  }

  void updateFilteredFiles(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredPdfFiles = _pdfFiles;
      } else {
        _filteredPdfFiles = _pdfFiles.where((pdfFile) {
          return pdfFile.name.toLowerCase().contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 30,
                          child: TextField(
                            controller: _booksearchController,
                            cursorHeight: 18,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              suffixIcon: const Icon(
                                Icons.search_outlined,
                                color: kBlueColor,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: 'Search Books to read',
                            ),
                            onChanged: updateFilteredFiles, // filtering here
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Read Books',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: ListView.builder(
                          itemCount: _filteredPdfFiles.length,
                          itemBuilder: (context, index) {
                            final pdfFile = _filteredPdfFiles[index];
                            final pdfFileName = pdfFile.name;

                            return Card(
                              elevation: 4,
                              color: kRedLightColor,
                              margin: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.file_present,
                                      color: kRedColor,
                                    ),
                                    title: Text(
                                      pdfFileName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: kBlueColor),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                      color: kWhiteColor,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        _openPdfViewer(pdfFile, pdfFileName);
                                      },
                                      child: const Text(
                                        'Read',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
