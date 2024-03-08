import 'package:book_finder/pages/book_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BookItem extends StatelessWidget {
  final String title;
  final List<dynamic> authors;
  final dynamic rating; // rating can be int or double
  final String thumbnailLink;
  final String selfLink;

  BookItem.fromJson(Map<String, dynamic> json, {super.key})
      : title = json["volumeInfo"]["title"] ?? "",
        authors = json["volumeInfo"]["authors"] ?? [],
        rating = json["volumeInfo"]["averageRating"] ?? "",
        thumbnailLink =
            json["volumeInfo"]["imageLinks"]["smallThumbnail"] ?? "",
        selfLink = json["selfLink"] ?? "";

  /*
    Pushes the BooksDetailsPage for this book
  */
  void pushBookDetailsPage(BuildContext context, String selfLink) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookDetailsPage(selfLink: selfLink)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      onPressed: () => pushBookDetailsPage(context, selfLink),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            thumbnailLink.isNotEmpty
                ? Image.network(thumbnailLink,
                    width: 150.0,
                    height: 150.0,
                    errorBuilder: ((context, error, stackTrace) =>
                        const SizedBox(
                            height: 64.0,
                            width: 64.0,
                            child: Icon(Icons.error))))
                : SvgPicture.asset(
                    "lib/images/imagemissing.svg",
                    height: 150.0,
                    width: 150.0,
                  ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                children: [
                  if (authors.isNotEmpty)
                    Text(
                      "by ${authors.join(", ")}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 8.0),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                      const SizedBox(width: 2.0),
                      Text(rating.toString().isNotEmpty
                          ? rating.toString()
                          : "-")
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
