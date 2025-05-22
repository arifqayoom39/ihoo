import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:ihoo/models/cart_model.dart';
import 'package:ihoo/models/coupon_model.dart';
import 'package:ihoo/models/orders_model.dart';
import 'auth_service.dart';

class DbService {
  late final Client _client;
  late final Account _account;
  late final Databases _database;
  late final Storage _storage;
  late final AuthService _authService;

  DbService() {
    _client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
      ..setProject('--------------'); // Your Appwrite project ID
    _account = Account(_client);
    _database = Databases(_client);
    _storage = Storage(_client);
    _authService = AuthService();
  }

  // Your existing methods for accessing the database, authentication, etc
  // USER DATA
  // Save user data after creating a new account
  Future saveUserData({required String name, required String email}) async {
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      Map<String, dynamic> data = {
        "name": name,
        "email": email,
      };

      await _database.createDocument(
        collectionId: 'users', // Your Appwrite collection ID for users
        documentId: userId,
        data: data, databaseId: '675d849e00233c3e38d1',
      );
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  // Update user data
  Future updateUserData({required Map<String, dynamic> extraData}) async {
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      await _database.updateDocument(
        collectionId: 'users', // Your Appwrite collection ID for users
        documentId: userId,
        data: extraData, databaseId: '675d849e00233c3e38d1',
      );
    } catch (e) {
      print("Error updating user data: $e");
    }
  }


  // Get current user ID (from Appwrite account)
  Future<String?> getUserId() async {
    try {
      final user = await _account.get();
      return user.$id; // Return the user ID
    } catch (e) {
      print("Error getting user ID: $e");
      return null;
    }
  }



  // Read current user data
  Future<Document> readUserData() async {
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      final response = await _database.getDocument(
        collectionId: 'users',
        documentId: userId, databaseId: '675d849e00233c3e38d1',
      );
      return response;
    } catch (e) {
      print("Error reading user data: $e");
      rethrow;
    }
  }

  // PROMOS AND BANNERS
  // Read promos
  Future<List<Document>> readPromos() async {
    try {
      final response = await _database.listDocuments(
        collectionId: 'shop_promos', databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error reading promos: $e");
      rethrow;
    }
  }

  // Read banners
  Future<List<Document>> readBanners() async {
    try {
      final response = await _database.listDocuments(
        collectionId: 'shop_banners', databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error reading banners: $e");
      rethrow;
    }
  }

  // DISCOUNTS
  // Read discount coupons
  Future<List<Document>> readDiscounts() async {
    try {
      final response = await _database.listDocuments(
        collectionId: '675d8533000d55d11a77',
        queries: [Query.orderDesc('discount')], databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error reading discounts: $e");
      rethrow;
    }
  }

  // Verify the coupon
  Future<List<Document>> verifyDiscount({required String code}) async {
    try {
      final response = await _database.listDocuments(
        collectionId: '675d8533000d55d11a77',
        queries: [Query.equal('code', code)], databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error verifying discount: $e");
      rethrow;
    }
  }

  // CATEGORIES
  // Read categories
  Future<List<Document>> readCategories() async {
    try {
      final response = await _database.listDocuments(
        collectionId: 'shop_categories',
        queries: [Query.orderDesc('priority')], databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error reading categories: $e");
      rethrow;
    }
  }

  // PRODUCTS
  // Read products of specific category
  Future<List<Document>> readProducts(String category) async {
  try {
    final response = await _database.listDocuments(
      collectionId: 'shop_products',
      queries: [Query.equal('category', category)], 
      databaseId: '675d849e00233c3e38d1', 
    );
    return response.documents;
  } catch (e) {
    print("Error reading products: $e");
    return []; // Return an empty list on error instead of rethrowing
  }
}


Future<String> reduceQuantity({required String productId, required int quantity}) async {
  try {
    String? userId = await _authService.getCurrentUserId();
    if (userId == null) throw Exception('User not found');

    // Debugging: Print out productId and quantity to ensure it's correct
    print('Reducing quantity for Product ID: $productId by $quantity');

    // Get the document for the product
    final response = await _database.getDocument(
      collectionId: 'shop_products', // Replace with correct collectionId
      documentId: productId, // Pass the correct productId
      databaseId: '675d849e00233c3e38d1', // Replace with correct databaseId
    );

    // Check if the document was found
    print('Response from getDocument: ${response.data}');
    if (response.data == null) {
      print('Document not found or no data returned');
      throw Exception('Product not found.');
    }

    int currentQuantity = response.data['quantity'];

    // Debugging: Print out current quantity
    print('Current quantity for $productId: $currentQuantity');

    // Ensure we have enough quantity to reduce
    if (currentQuantity >= quantity) {
      // Debugging: Print out the updated quantity
      print('Updating quantity for $productId. New quantity: ${currentQuantity - quantity}');
      
      // Update the product document
      await _database.updateDocument(
        collectionId: 'shop_products',
        documentId: productId,
        data: {
          "quantity": currentQuantity - quantity,
        },
        databaseId: '675d849e00233c3e38d1',
      );
      return "Quantity reduced";
    } else {
      print('Insufficient quantity to reduce. Current: $currentQuantity, Requested: $quantity');
      return "Insufficient quantity to reduce";
    }
  } catch (e) {
    // Add better error handling and debug info
    print("Error reducing quantity: $e");
    if (e is AppwriteException) {
      print("AppwriteError: ${e.message}");
    }
    return "Error reducing quantity: $e";
  }
}
  // Search products by doc IDs
  Future<List<Document>> searchProducts(List<String> docIds) async {
    try {
      final response = await _database.listDocuments(
        collectionId: 'shop_products',
        queries: [Query.equal('documentId', docIds)], databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error searching products: $e");
      rethrow;
    }
  }

  // Search products by name
  Future<List<Document>> searchProductsByName(String name) async {
    try {
      final response = await _database.listDocuments(
        collectionId: 'shop_products',
        queries: [Query.search('name', name)], 
        databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error searching products by name: $e");
      rethrow;
    }
  }

  // Get all products regardless of category
  Future<List<Document>> getAllProducts() async {
    try {
      final response = await _database.listDocuments(
        collectionId: 'shop_products',
        databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error getting all products: $e");
      return []; // Return empty list on error
    }
  }

  // Update product rating
  Future<String> updateProductRating({
    required String productId,
    required double newRating, // The user's new rating (e.g., 4.5)
  }) async {
    try {
      // 1. Get the current product document
      final productDoc = await _database.getDocument(
        databaseId: '675d849e00233c3e38d1',
        collectionId: 'shop_products',
        documentId: productId,
      );

      double currentAvgRating = (productDoc.data['rating'] ?? 0.0).toDouble();
      int currentRatingCount = productDoc.data['ratingCount'] ?? 0;

      // 2. Calculate the new average rating
      // New Average = ((Old Average * Old Count) + New Rating) / (Old Count + 1)
      double updatedAvgRating = ((currentAvgRating * currentRatingCount) + newRating) / (currentRatingCount + 1);
      int updatedRatingCount = currentRatingCount + 1;

      // 3. Update the product document
      await _database.updateDocument(
        databaseId: '675d849e00233c3e38d1',
        collectionId: 'shop_products',
        documentId: productId,
        data: {
          'rating': updatedAvgRating, // Store the new average
          'ratingCount': updatedRatingCount, // Increment the count
        },
      );
      return "Rating updated successfully";
    } on AppwriteException catch (e) {
      print("Error updating product rating: ${e.message}");
      return "Error updating rating: ${e.message}";
    } catch (e) {
      print("Error updating product rating: $e");
      return "Error updating rating";
    }
  }

  // CART
  // Read user cart
  Future<List<Document>> readUserCart() async {
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      final response = await _database.listDocuments(
        collectionId: '675d8563001d84415f58',
        queries: [Query.equal('user_id', userId)], databaseId: '675d849e00233c3e38d1',
      );
      return response.documents;
    } catch (e) {
      print("Error reading user cart: $e");
      rethrow;
    }
  }

  // Add product to cart
  
  Future<String> addToCart({required CartModel cartData}) async {
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      // Check if product already exists in the cart
      final response = await _database.listDocuments(
        collectionId: '675d8563001d84415f58',
        queries: [
          Query.equal('product_id', cartData.productId),
          Query.equal('user_id', userId),
        ],
        databaseId: '675d849e00233c3e38d1',
      );

      if (response.documents.isNotEmpty) {
        // If the product exists, update its quantity
        final existingDocument = response.documents[0];
        int currentQuantity = existingDocument.data['quantity'];
        
        await _database.updateDocument(
          collectionId: '675d8563001d84415f58',
          documentId: existingDocument.$id,
          data: {
            "quantity": currentQuantity + cartData.quantity,
          },
          databaseId: '675d849e00233c3e38d1',
        );
        return "Product quantity updated in cart";
      } else {
        // If the product doesn't exist, create a new document
        await _database.createDocument(
          collectionId: '675d8563001d84415f58',
          documentId: ID.unique(), // Generate unique document ID
          data: {
            "product_id": cartData.productId,
            "quantity": cartData.quantity,
            "user_id": userId,
          },
          databaseId: '675d849e00233c3e38d1',
        );
        return "Product added to cart";
      }
    } catch (e) {
      print("Error adding to cart: $e");
      return "Error adding to cart";
    }
  }

  // Decrease product quantity in the cart
  Future<String> decreaseCount({required String productId}) async {
  try {
    String? userId = await _authService.getCurrentUserId();
    if (userId == null) throw Exception('User not found');

    // Get the document for the product
    final response = await _database.listDocuments(
      collectionId: '675d8563001d84415f58',
      queries: [
        Query.equal('product_id', productId),
        Query.equal('user_id', userId),
      ],
      databaseId: '675d849e00233c3e38d1',
    );

    if (response.documents.isNotEmpty) {
      final existingDocument = response.documents[0];
      int currentQuantity = existingDocument.data['quantity'];

      // Ensure quantity is greater than 1 before decreasing
      if (currentQuantity > 1) {
        await _database.updateDocument(
          collectionId: '675d8563001d84415f58',
          documentId: existingDocument.$id,
          data: {
            "quantity": currentQuantity - 1,
          },
          databaseId: '675d849e00233c3e38d1',
        );
        return "Quantity decreased";
      } else {
        return "Cannot decrease quantity further";
      }
    } else {
      return "Product not found in cart";
    }
  } catch (e) {
    print("Error decreasing quantity: $e");
    return "Error decreasing quantity: $e";
  }
}

  // Delete item from cart
  Future<String> deleteItemFromCart({required String productId}) async {
  try {
    print("Attempting to delete item with Product ID: $productId");

    // Check if the product exists in the cart
    final response = await _database.listDocuments(
      collectionId: '675d8563001d84415f58',
      queries: [
        Query.equal('product_id', productId),
        Query.equal('user_id', await _authService.getCurrentUserId() ?? ""),
      ],
      databaseId: '675d849e00233c3e38d1',
    );

    if (response.documents.isNotEmpty) {
      final documentToDelete = response.documents[0];

      // If the product exists, proceed with deletion
      await _database.deleteDocument(
        collectionId: '675d8563001d84415f58',
        documentId: documentToDelete.$id,
        databaseId: '675d849e00233c3e38d1',
      );
      print("Item successfully deleted from cart.");
      return "Item deleted from cart";
    } else {
      return "Product not found in cart";
    }
  } catch (e) {
    print("Error deleting item from cart: $e");

    // Check if it's an AppwriteException
    if (e is AppwriteException) {
      print("Appwrite Error: ${e.message}");
    }

    return "Error deleting item from cart: $e";
  }
}



  // Empty the user's cart
  Future<String> emptyCart() async {
    try {
      String? userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      final response = await _database.listDocuments(
        collectionId: '675d8563001d84415f58',
        queries: [Query.equal('user_id', userId)],
        databaseId: '675d849e00233c3e38d1',
      );

      for (var document in response.documents) {
        await _database.deleteDocument(
          collectionId: '675d8563001d84415f58',
          documentId: document.$id,
          databaseId: '675d849e00233c3e38d1',
        );
      }
      return "Cart emptied";
    } catch (e) {
      print("Error emptying cart: $e");
      return "Error emptying cart";
    }
  }


  // ORDERS
  // Create a new order
  Future<void> createOrder({required OrdersModel orderData}) async {
  try {
    // Convert products to a list of JSON strings
    List<String> productStrings = orderData.products.map((product) => product.toJsonString()).toList();

    // Prepare the order data to save in Appwrite
    Map<String, dynamic> orderJson = {
      'email': orderData.email,
      'name': orderData.name,
      'phone': orderData.phone,
      'address': orderData.address,
      'status': orderData.status,
      'user_id': orderData.user_id,
      'discount': orderData.discount,
      'total': orderData.total,
      'created_at': orderData.created_at,
      'products': productStrings, // Save products as a list of JSON strings
    };

    // Create the order document in Appwrite
    await _database.createDocument(
      collectionId: '675d856e003514bd96a2',
      documentId: 'unique()', // Use unique ID generation for each order
      data: orderJson,
      databaseId: '675d849e00233c3e38d1',
    );
    print('Order created successfully');
  } catch (e) {
    print('Error creating order: $e');
  }
}


  // Read user orders
  Future<List<Document>> readOrders() async {
  try {
    // Get the current user ID
    String? userId = await _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not found');
    }

    // Fetch the orders from the 'orders' collection where 'user_id' matches the current user ID
    final response = await _database.listDocuments(
      collectionId: '675d856e003514bd96a2',  // Replace with your collection ID
      queries: [
        Query.equal('user_id', userId),  // Filter orders by user_id
      ],
      databaseId: '675d849e00233c3e38d1',  // Replace with your database ID
    );

    return response.documents;
  } catch (e) {
    print("Error reading orders: $e");
    rethrow;
  }
}


  // Update order status
  Future<String> updateOrderStatus(
    {required String orderId, required Map<String, dynamic> statusData}) async {
  try {
    // Update the order document in the 'orders' collection using the order ID
    final response = await _database.updateDocument(
      collectionId: '675d856e003514bd96a2',  // Replace with your collection ID
      documentId: orderId,  // ID of the order to update
      data: statusData,  // Data to update (e.g., {'status': 'DELIVERED'})
      databaseId: '675d849e00233c3e38d1',  // Replace with your database ID
    );

    return "Order status updated to: ${statusData['status']}";
  } catch (e) {
    print("Error updating order status: $e");
    return "Error updating order status";
  }
}
}
