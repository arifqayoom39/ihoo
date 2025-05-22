/*import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String productId;
  int quantity;
  CartModel({
    required this.productId,
    required this.quantity,
  });

  // convert json to object model
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json["product_id"] ?? "",
      quantity: json["quantity"] ?? 0,
    );
  }

  // Convert List<QueryDocumentSnapshot> to List<CartModel>
  static List<CartModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((e) => CartModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
  }
}*/


import 'package:appwrite/models.dart';  // Import Appwrite models

class CartModel {
  final String productId;
  int quantity;

  CartModel({
    required this.productId,
    required this.quantity,
  });

  // Convert JSON to CartModel object
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json["product_id"] ?? "",
      quantity: json["quantity"] ?? 0,
    );
  }

  // Convert List of Documents to List of CartModel
  static List<CartModel> fromJsonList(List<Document> list) {
    return list
        .map((doc) => CartModel.fromJson(doc.data as Map<String, dynamic>))
        .toList();
  }
}

