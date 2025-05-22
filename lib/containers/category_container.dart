import 'package:appwrite/models.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';  // Import CachedNetworkImage

class CategoryContainer extends StatefulWidget {
  const CategoryContainer({super.key});

  @override
  State<CategoryContainer> createState() => _CategoryContainerState();
}

class _CategoryContainerState extends State<CategoryContainer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Document>>(
      future: DbService().readCategories(),  // Future instead of Stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.white,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey.shade200,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          List<CategoriesModel> categories = snapshot.data!
              .map((doc) => CategoriesModel.fromJson(doc.data, doc.$id))  // Updated mapping
              .toList();

          if (categories.isEmpty) {
            return SizedBox();
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map((cat) => CategoryButton(
                          imagepath: cat.image,
                          name: cat.name,
                        ))
                    .toList(),
              ),
            );
          }
        } else {
          return SizedBox();
        }
      },
    );
  }
}

class CategoryButton extends StatefulWidget {
  final String imagepath, name;
  const CategoryButton({super.key, required this.imagepath, required this.name});

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/specific", arguments: {
        "name": widget.name
      }),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CachedNetworkImage(
                imageUrl: widget.imagepath,
                height: 36,
                width: 36,
                placeholder: (context, url) => SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue.shade200,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  color: Colors.red.shade300,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



