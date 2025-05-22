import 'package:appwrite/models.dart';

class ProductsModel {
  String name;
  String description;
  String image; // Main image
  List<String> images; // Array of additional images
  int old_price;
  int new_price;
  String category;
  String id;
  int maxQuantity;
  double rating; // Average rating
  int ratingCount; // Number of ratings

  ProductsModel({
    required this.name,
    required this.description,
    required this.image,
    required this.images, // Add images to constructor
    required this.old_price,
    required this.new_price,
    required this.category,
    required this.id,
    required this.maxQuantity,
    required this.rating, // Add rating
    required this.ratingCount, // Add ratingCount
  });

  // To convert the JSON to object model
  factory ProductsModel.fromJson(Map<String, dynamic> json, String id) {
    // Handle potential null or incorrect type for images list
    List<String> imageList = [];
    if (json["images"] is List) {
      // Ensure all elements are strings
      imageList = List<String>.from(json["images"].map((item) => item.toString()));
    } else if (json["images"] is String) {
      // Handle case where images might be stored as a single string (e.g., comma-separated)
      // This part might need adjustment based on how images are actually stored if not a list
      imageList = [json["images"]];
    }

    return ProductsModel(
      name: json["name"] ?? "",
      description: json["desc"] ?? "no description",
      image: json["image"] ?? "", // Keep main image handling
      images: imageList, // Assign the parsed list
      new_price: json["new_price"] ?? 0,
      old_price: json["old_price"] ?? 0,
      category: json["category"] ?? "",
      maxQuantity: json["quantity"] ?? 0,
      rating: (json["rating"] ?? 0.0).toDouble(), // Default to 0.0 if null
      ratingCount: json["ratingCount"] ?? 0, // Default to 0 if null
      id: id,
    );
  }

  // Convert List<Document> to List<ProductsModel>
  static List<ProductsModel> fromJsonList(List<Document> list) {
    return list.map((e) => ProductsModel.fromJson(e.data, e.$id)).toList();
  }
}
