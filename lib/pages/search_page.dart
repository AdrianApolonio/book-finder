import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../components/book_item.dart';
import 'settings_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // search does not require authorization
  TextEditingController search = TextEditingController();
  final String authority = "www.googleapis.com";
  final String unencodedPath = "/books/v1/volumes";
  static const success = 200;

  bool loading = false;
  bool noResults = false;
  int totalItems = 0;
  int startIndex = 0;
  String searchQuery = "a";

  List<BookItem> books = [];

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(loadMoreBooks);
    searchBook("a");
  }

  void loadMoreBooks() async {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        startIndex < totalItems) {
      print("loading more books");
      // "www.googleapis.com/books/v1/volumes?q="
      Response res = await http.get(Uri.https(authority, unencodedPath, {
        "q": searchQuery,
        "fields":
            "totalItems,items(volumeInfo(title,authors,imageLinks(smallThumbnail),averageRating),selfLink)",
        "maxResults": "40",
        "startIndex": "$startIndex"
      }));
      if (res.statusCode == success) {
        var resJson = convert.jsonDecode(res.body) as Map<String, dynamic>;
        if (resJson.isEmpty) {
          // case that returns empty
          startIndex = 1;
          totalItems = 0;
          return;
        }

        // check if json contains imageLink, if not set an empty one
        for (dynamic json in resJson["items"]) {
          if (json["volumeInfo"]["imageLinks"] == null) {
            json["volumeInfo"]["imageLinks"] = {"smallThumbnail": ""};
          }
        }

        totalItems = resJson["totalItems"];

        // parse json
        await parseItems(resJson["items"]);
      } else {
        // at some point it will return 400. stop further loadMoreBook calls
        startIndex = 1;
        totalItems = 0;
      }
    }
  }

  void searchBook(String searchQuery) async {
    books.clear();
    totalItems = 0;
    startIndex = 0;
    this.searchQuery = searchQuery;
    if (mounted) {
      setState(() {
        loading = true;
        noResults = false;
      });
    }

    // "www.googleapis.com/books/v1/volumes?q="
    Response res = await http.get(Uri.https(authority, unencodedPath, {
      "q": searchQuery,
      "fields":
          "totalItems,items(volumeInfo(title,authors,imageLinks(smallThumbnail),averageRating),selfLink)",
      "maxResults": "40",
      "startIndex": "$startIndex"
    }));
    if (res.statusCode == success) {
      var resJson = convert.jsonDecode(res.body) as Map<String, dynamic>;
      if (resJson.isEmpty) {
        // case that returns empty
        if (mounted) {
          setState(() {
            loading = false;
            noResults = true;
          });
          return;
        }
      }

      // check if json contains imageLink, if not set an empty one
      for (dynamic json in resJson["items"]) {
        if (json["volumeInfo"]["imageLinks"] == null) {
          json["volumeInfo"]["imageLinks"] = {"smallThumbnail": ""};
        }
      }
      totalItems = resJson["totalItems"];

      // parse json
      await parseItems(resJson["items"]);
    } else {
      // do nothing
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  /*
    Creates a BookItem object for each item in items
  */
  Future parseItems(dynamic items) async {
    List<BookItem> newBooks = [];
    for (dynamic item in items) {
      print(item);

      BookItem book = BookItem.fromJson(item);
      newBooks.add(book);
    }
    setState(() => books.addAll(newBooks));
    startIndex += 41;
  }

  void pushSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                    onPressed: () => pushSettingsPage(),
                    icon: const Icon(Icons.menu_rounded)),
              ),
            ],
          ),
          TextField(
            controller: search,
            onSubmitted: (text) => searchBook(text),
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: "Search for books"),
          ),
          loading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : noResults
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("No results found..."),
                    )
                  : Expanded(
                      child: ListView(
                          controller: scrollController,
                          shrinkWrap: true,
                          children: books.toList())),
        ],
      ),
    )));
  }
}
