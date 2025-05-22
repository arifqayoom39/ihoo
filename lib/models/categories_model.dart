/*import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel{
  String name, image,id;
int priority;

CategoriesModel({
  required this.id,
  required this.name,
  required this.image,
  required this.priority
});

// convert to json to object model
 factory CategoriesModel.fromJson(Map<String,dynamic> json,String id){
    return CategoriesModel(
      name: json["name"]??"",
      image: json["image"]??"",
      priority: json["priority"]??0,
      id: id??"",
    );
  }
    // Convert List<QueryDocumentSnapshot> to List<CategoriesModel>
  static List<CategoriesModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list.map((e) => CategoriesModel.fromJson(e.data() as Map<String, dynamic>, e.id)).toList();
  }

}*/


import 'package:appwrite/models.dart';

class CategoriesModel {
  final String id;
  final String name;
  final String image;
  final int priority;

  CategoriesModel({
    required this.id,
    required this.name,
    required this.image,
    required this.priority,
  });

  factory CategoriesModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoriesModel(
      id: id,
      name: json['name'] ?? 'Unknown Category',
      image: json['image'] ?? 'default_image.png',
      priority: json['priority'] is int ? json['priority'] : 0,
    );
  }

  static List<CategoriesModel> fromJsonList(List<Document> docs) {
    return docs
        .map((doc) {
          final data = doc.data as Map<String, dynamic>?;
          if (data == null) return null;
          return CategoriesModel.fromJson(data, doc.$id);
        })
        .whereType<CategoriesModel>() // Filters out null values
        .toList();
  }
}

