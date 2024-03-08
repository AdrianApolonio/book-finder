import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert' as convert;

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.selfLink});

  final String selfLink;

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  static const success = 200;
  bool loading = true;
  String title = "";
  String imageLink = "";
  List<dynamic> authors = [];
  String publisher = "";
  String publishDate = "";
  String description = "";
  int pageCount = -1;
  String language = "";

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  /*
    Gets information about this book
  */
  void getDetails() async {
    // print("fetching from " + widget.selfLink);
    try {
      Response res = await http.get(Uri.parse(widget.selfLink));
      if (res.statusCode == success) {
        var resJson = convert.jsonDecode(res.body) as Map<String, dynamic>;
        var volumeInfo = resJson["volumeInfo"];
        if (mounted) {
          setState(() {
            // sometimes a book doesn't contain specific info, check if it does
            if (volumeInfo["title"] != null) {
              title = volumeInfo["title"];
            }
            if (volumeInfo["authors"] != null) {
              authors = volumeInfo["authors"];
            }
            if (volumeInfo["publisher"] != null) {
              publisher = volumeInfo["publisher"];
            }
            if (volumeInfo["publishedDate"] != null) {
              publishDate = volumeInfo["publishedDate"];
            }
            if (volumeInfo["description"] != null) {
              // for some reason the description is in html, so parse it
              description = parse(volumeInfo["description"]).body!.text;
            }
            if (volumeInfo["pageCount"] != null) {
              pageCount = volumeInfo["pageCount"];
            }
            if (volumeInfo["imageLinks"] != null) {
              imageLink = volumeInfo["imageLinks"]["thumbnail"];
            }
            if (volumeInfo["language"] != null) {
              language = volumeInfo["language"];
            }
          });
        }
      } else {
        // this should never occur... but if it does leave this page
        Navigator.pop(context);
      }
    } catch (error) {
      // Navigator.pop(context);
    }
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
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  imageLink.isNotEmpty
                      ? Image.network(
                          height: 300.0,
                          width: 300.0,
                          fit: BoxFit.contain,
                          imageLink)
                      : SvgPicture.asset(
                          "lib/images/imagemissing.svg",
                          height: 300.0,
                          width: 300.0,
                        ),
                  const SizedBox(height: 15.0),
                  if (authors.isNotEmpty)
                    Text("By ${authors.join(", ")}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  if (publishDate.isNotEmpty)
                    Text(
                      "Published: $publishDate",
                      textAlign: TextAlign.center,
                    ),
                  if (publisher.isNotEmpty)
                    Text(
                      "Publisher: $publisher",
                      textAlign: TextAlign.center,
                    ),
                  if (pageCount != -1)
                    Text("Page count: $pageCount", textAlign: TextAlign.center),
                  if (language.isNotEmpty)
                    Text("Language: $language", textAlign: TextAlign.center),
                  if (description.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Text(
                        "Description",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(description,
                        style: const TextStyle(fontSize: 16.0)),
                  ),
                ])),
        ],
      ),
    )));
  }
}
