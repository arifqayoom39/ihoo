

import 'dart:async';
import 'package:appwrite/appwrite.dart'; // Add this import
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/cart_model.dart';
import 'package:ihoo/models/products_model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  bool isLoading = true;

  List<CartModel> carts = [];
  List<String> cartUids = [];
  List<ProductsModel> products = [];
  int totalCost = 0;
  int totalQuantity = 0;

  // Timer for polling data
  Timer? _timer;

  // Appwrite Realtime subscription
  RealtimeSubscription? _subscription;

  CartProvider() {
    readCartData();
    _subscribeToRealtimeUpdates(); // Subscribe to real-time updates
  }

  // Subscribe to real-time updates
  void _subscribeToRealtimeUpdates() {
    final client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('--------------');
    final realtime = Realtime(client);

    _subscription = realtime.subscribe(['databases.675d849e00233c3e38d1.collections.675d8563001d84415f58.documents']);

    _subscription?.stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.create') ||
          response.events.contains('databases.*.collections.*.documents.*.update') ||
          response.events.contains('databases.*.collections.*.documents.*.delete')) {
        readCartData(); // Refresh cart data on any change
      }
    });
  }

  // Start reading the cart data (polling)
  void readCartData() {
    isLoading = true;
    // Fetch the cart data once initially
    DbService().readUserCart().then((cartDocs) {
      List<CartModel> cartsData =
          CartModel.fromJsonList(cartDocs); // Assuming cartDocs is a List<Document>
      carts = cartsData;

      cartUids = [];
      for (int i = 0; i < carts.length; i++) {
        cartUids.add(carts[i].productId);
        print("cartUids: ${cartUids[i]}");
      }

      if (carts.isNotEmpty) {
        readCartProducts(cartUids); // Fetch the product data
      }
      isLoading = false;
      notifyListeners();
    });

    // Optional: You could implement polling (every 10 seconds, for example)
    _timer = Timer.periodic(Duration(seconds: 10), (_) {
      refreshCartData();
    });
  }

  // Refresh cart data manually (can be triggered for polling)
  void refreshCartData() {
    DbService().readUserCart().then((cartDocs) {
      List<CartModel> cartsData =
          CartModel.fromJsonList(cartDocs); // Assuming cartDocs is a List<Document>
      carts = cartsData;

      cartUids = [];
      for (int i = 0; i < carts.length; i++) {
        cartUids.add(carts[i].productId);
      }

      if (carts.isNotEmpty) {
        readCartProducts(cartUids); // Fetch the product data
      }
      notifyListeners();
    });
  }

  // Read products from the cart
  void readCartProducts(List<String> uids) {
    DbService().searchProducts(uids).then((productDocs) {
      List<ProductsModel> productsData =
          ProductsModel.fromJsonList(productDocs); // Assuming productDocs is a List<Document>
      products = productsData;

      isLoading = false;
      addCost(products, carts); // Calculate total cost
      calculateTotalQuantity();
      notifyListeners();
    });
  }

  // Add the total cost of all products in the cart
  void addCost(List<ProductsModel> products, List<CartModel> carts) {
    totalCost = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < carts.length; i++) {
        totalCost += carts[i].quantity * products[i].new_price;
      }
      notifyListeners();
    });
  }

  // Calculate the total quantity of products
  void calculateTotalQuantity() {
    totalQuantity = 0;
    for (int i = 0; i < carts.length; i++) {
      totalQuantity += carts[i].quantity;
    }
    print("totalQuantity: $totalQuantity");
    notifyListeners();
  }

  // Add a product to the cart
  void addToCart(CartModel cartModel) {
    DbService().addToCart(cartData: cartModel);
    notifyListeners();
  }

  // Delete a product from the cart
  void deleteItem(String productId) {
    DbService().deleteItemFromCart(productId: productId);
    readCartData(); // Refresh cart data
    notifyListeners();
  }

  // Decrease the count of a product
  void decreaseCount(String productId) async {
    await DbService().decreaseCount(productId: productId);
    readCartData(); // Refresh cart data
    notifyListeners();
  }

  // Cancel polling and real-time subscription when not needed
  void cancelProvider() {
    _timer?.cancel();
    _subscription?.close();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}

