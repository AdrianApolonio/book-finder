import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert' as convert;
import '../components/book_info.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.selfLink});

  final String selfLink;

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  static const success = 200;
  bool loading = true;
  BookInfo book = BookInfo();

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  /*
    Gets information about this book
  */
  void getDetails() async {
    try {
      Response res = await http.get(Uri.parse(widget.selfLink));
      if (res.statusCode == success) {
        var resJson = convert.jsonDecode(res.body) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            book = BookInfo.mapJsonToBookInfo(resJson);
          });
        }
      } else {
        // this should never occur... but if it does leave this page
        Navigator.pop(context);
      }
    } catch (error) {}
    if (mounted) {
      setState(() => loading = false);
    }
  }

  void popBookDetailsPage(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => popBookDetailsPage(context)),
              )
            ]),
            loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        book.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    book.thumbnailLink.isNotEmpty
                        ? Image.network(
                            height: 300.0,
                            width: 300.0,
                            fit: BoxFit.contain,
                            book.thumbnailLink)
                        : SvgPicture.asset(
                            "lib/images/imagemissing.svg",
                            height: 300.0,
                            width: 300.0,
                          ),
                    const SizedBox(height: 15.0),
                    if (book.authors.isNotEmpty)
                      Text("By ${book.authors.join(", ")}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (book.publishDate.isNotEmpty)
                      Text(
                        "Published: ${book.publishDate}",
                        textAlign: TextAlign.center,
                      ),
                    if (book.publisher.isNotEmpty)
                      Text(
                        "Publisher: ${book.publisher}",
                        textAlign: TextAlign.center,
                      ),
                    if (book.pageCount != -1)
                      Text("Page count: ${book.pageCount}",
                          textAlign: TextAlign.center),
                    if (book.language.isNotEmpty)
                      Text("Language: ${book.language}",
                          textAlign: TextAlign.center),
                    if (book.categories.isNotEmpty)
                      Text(
                        "Categories: ${book.categories.join(", ")}",
                        textAlign: TextAlign.center,
                      ),
                    if (book.description.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Text(
                          "Description",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, bottom: 20.0),
                      child: Text(book.description,
                          style: const TextStyle(fontSize: 16.0)),
                    ),
                  ])),
          ],
        ),
      ),
    )));
  }
}
