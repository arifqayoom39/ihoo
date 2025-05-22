import 'dart:async';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String name = "User";
  String email = "";
  String address = "";
  String phone = "";

  UserProvider() {
    loadUserData();
  }

  // Load user profile data
  Future<void> loadUserData() async {
    try {
      final response = await DbService().readUserData(); // This returns a Future<Document>
      final data = response.data as Map<String, dynamic>; // Accessing the document data
      final UserModel user = UserModel.fromJson(data); // Converting the data to UserModel

      name = user.name;
      email = user.email;
      address = user.address;
      phone = user.phone;

      notifyListeners(); // Notify listeners after data is loaded
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  void cancelProvider() {
    name = "User";
    email = "";
    address = "";
    phone = "";
    notifyListeners(); // Notify listeners that user data has been reset
  }

  @override
  void dispose() {
    super.dispose();
  }
}
