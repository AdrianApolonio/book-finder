import 'package:html/parser.dart';

class BookInfo {
  final String title;
  final List<dynamic> authors;
  final dynamic rating; // rating can be int or double
  final String thumbnailLink;
  final String selfLink;
  final String publisher;
  final String publishDate;
  final String description;
  final int pageCount;
  final String language;
  final List<dynamic> categories;

  BookInfo(
      {this.title = "",
      this.authors = const [],
      this.rating = "",
      this.thumbnailLink = "",
      this.selfLink = "",
      this.publisher = "",
      this.publishDate = "",
      this.description = "",
      this.pageCount = -1,
      this.language = "",
      this.categories = const []});

  static BookInfo mapJsonToBookInfo(Map<String, dynamic> json) {
    return BookInfo(
        title: json["volumeInfo"]["title"] ?? "",
        authors: json["volumeInfo"]["authors"] ?? [],
        rating: json["volumeInfo"]["averageRating"] ?? "",
        thumbnailLink: json["volumeInfo"]["imageLinks"] != null
            ? json["volumeInfo"]["imageLinks"]["smallThumbnail"]
            : "",
        selfLink: json["selfLink"] ?? "",
        publisher: json["volumeInfo"]["publisher"] ?? "",
        publishDate: json["volumeInfo"]["publishedDate"] ?? "",
        description: json["volumeInfo"]["description"] != null
            ? parse(json["volumeInfo"]["description"]).body!.text
            : "",
        pageCount: json["volumeInfo"]["pageCount"] ?? -1,
        language: json["volumeInfo"]["language"] ?? "",
        categories: json["volumeInfo"]["categories"] ?? []);
  }
}
