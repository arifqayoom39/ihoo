import 'dart:convert';

import 'package:appwrite/models.dart';

class OrdersModel {
  String id, email, name, phone, status, user_id, address;
  int discount, total, created_at;
  List<OrderProductModel> products; // This will now hold the mapped product models

  OrdersModel({
    required this.id,
    required this.created_at,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    required this.status,
    required this.user_id,
    required this.discount,
    required this.total,
    required this.products,
  });

  // Convert Appwrite's Document to OrdersModel
  factory OrdersModel.fromJson(Document doc) {
    final data = doc.data;
    return OrdersModel(
      id: doc.$id,
      created_at: data['created_at'] ?? 0,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      status: data['status'] ?? '',
      address: data['address'] ?? '',
      user_id: data['user_id'] ?? '',
      discount: data['discount'] ?? 0,
      total: data['total'] ?? 0,
      products: List<OrderProductModel>.from(
        // Mapping string data into ProductModel
        (data['products'] as List).map((e) => OrderProductModel.fromJson(e)),
      ),
    );
  }

  // Convert a list of Documents to a list of OrdersModels
  static List<OrdersModel> fromJsonList(List<Document> docs) {
    return docs.map((doc) => OrdersModel.fromJson(doc)).toList();
  }
}

class OrderProductModel {
  String id, name, image;
  int quantity, single_price, total_price;

  OrderProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.single_price,
    required this.total_price,
  });

  // Convert string (e.g., product data in the form of a map) to ProductModel
  factory OrderProductModel.fromJson(String jsonStr) {
    final Map<String, dynamic> json = jsonDecode(jsonStr);
    return OrderProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 0,
      single_price: json['single_price'] ?? 0,
      total_price: json['total_price'] ?? 0,
    );
  }

  // Convert ProductModel to a string for storing as JSON in the array
  String toJsonString() {
    final Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'image': image,
      'quantity': quantity,
      'single_price': single_price,
      'total_price': total_price,
    };
    return jsonEncode(json);
  }
}
