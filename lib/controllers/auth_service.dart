/*import 'package:ihoo/controllers/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
   // create new account using email password method
  Future<String> createAccountWithEmail(String name, String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    await  DbService().saveUserData(name: name, email: email);
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

   // login with email password method
  Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

 // logout the user
  Future logout() async {
    await FirebaseAuth.instance.signOut();
 
  }
  // reset the password
  Future resetPassword(String email) async {
    try{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return "Mail Sent";
    }
   on FirebaseAuthException  catch(e){
    return e.message.toString();
    }
  }

  // check whether the user is sign in or not
  Future<bool> isLoggedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}*/


import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AuthService {
  final Client _client = Client();
  late Account _account;
  late Databases _database;

  // Replace with your Appwrite endpoint and project ID
  AuthService() {
    _client.setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
      .setProject('--------------'); // Your Appwrite project ID

    // Initialize Account and Databases with the client
    _account = Account(_client);
    _database = Databases(_client);
  }

  // Create new account using email/password method
  Future<String> createAccountWithEmail(String name, String email, String password) async {
    try {
      print("Attempting to create account for: $email");
      
      // Step 1: Create the user account
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Step 2: Save the user's data in the users collection
      await _saveUserDataInCollection(user.$id, name, email);

      print("Account created successfully for: $email");
      return "Account Created";
    } on AppwriteException catch (e) {
      print("Error creating account: ${e.message}");
      return e.message ?? "Unknown error";
    }
  }

  // Save user data in the 'users' collection in Appwrite
  Future<void> _saveUserDataInCollection(String userId, String name, String email) async {
    try {
      print("Saving user data to collection...");

      // Here, we use userId as the documentId, ensuring the user data is stored with the same ID
      await _database.createDocument(
        databaseId: '675d849e00233c3e38d1', // Your database ID
        collectionId: 'users', // Your users collection ID
        documentId: userId, // Use userId as the document ID
        data: {
          'name': name,
          'email': email,
        },
      );
      print("User data saved successfully for: $email");
    } on AppwriteException catch (e) {
      print("Error saving user data: ${e.message}");
    }
  }

  // Login with email/password method
  Future<String> loginWithEmail(String email, String password) async {
    try {
      print("Attempting login for: $email");
      
      // Create a session to log the user in
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      
      // Retrieve current user info after login
      await getCurrentUser();

      print("Login successful for: $email");
      return "Login Successful";
    } on AppwriteException catch (e) {
      print("Login error: ${e.message}");
      return e.message ?? "Unknown error";
    }
  }

  // Logout the user
  Future<void> logout() async {
    try {
      print("Attempting logout...");
      await _account.deleteSession(sessionId: 'current');  // 'current' will delete the current session
      print("Logout successful");
    } on AppwriteException catch (e) {
      print("Logout error: ${e.message}");
    }
  }

  // Reset the password (send reset email)
  Future<String> resetPassword(String email) async {
    try {
      print("Sending password reset email to: $email");
      await _account.createRecovery(
        email: email,
        url: 'https://your-redirect-url.com', // Replace with your redirect URL
      );
      print("Password reset email sent to: $email");
      return "Password Reset Email Sent";
    } on AppwriteException catch (e) {
      print("Error sending password reset email: ${e.message}");
      return e.message ?? "Unknown error";
    }
  }

  // Check whether the user is logged in or not
  Future<bool> isLoggedIn() async {
    try {
      print("Checking if user is logged in...");
      final session = await _account.getSession(sessionId: 'current');
      if (session != null) {
        print("User is logged in with session ID: ${session.$id}");
        return true;
      }
      return false;  // If no session, user is not logged in
    } on AppwriteException catch (e) {
      print("Error checking login status: ${e.message}");
      return false;
    }
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    try {
      print("Fetching current user...");
      final user = await _account.get();
      print("Current user: ${user.name} (${user.email})");
      return user;
    } on AppwriteException catch (e) {
      print("Error fetching user: ${e.message}");
      return null;
    }
  }

  // Get current user's ID
  Future<String?> getCurrentUserId() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        print("Current user ID: ${user.$id}");
        return user.$id;
      }
      return null;
    } catch (e) {
      print("Error fetching current user ID: $e");
      return null;
    }
  }
}




/*import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AuthService {
  final Client _client;
  late final Account _account;

  // Initialize Appwrite client and services
  AuthService()
      : _client = Client(),
        _account = Account(Client()) {
    _client.setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
          .setProject('--------------'); // Your Appwrite project ID
  }

  // Create a new account using email/password
  Future<String> createAccountWithEmail(String name, String email, String password) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return "Account Created";
    } on AppwriteException catch (e) {
      return e.message ?? "Unknown error";
    }
  }

  // Login with email/password
  Future<String> loginWithEmail(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return "Login Successful";
    } on AppwriteException catch (e) {
      return e.message ?? "Unknown error";
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      print('Logout Error: ${e.message}');
    }
  }

  // Get current user details
  Future<User> getCurrentUser() async {
    try {
      final user = await _account.get();
      return user;
    } on AppwriteException catch (e) {
      print("Error getting current user: ${e.message}");
      rethrow;
    }
  }

  // Get current user ID
  Future<String?> getUserId() async {
    try {
      final user = await getCurrentUser();
      return user.$id;
    } catch (e) {
      print("Error getting user ID: $e");
      return null;
    }
  }

// Reset the password (send reset email)
  Future<String> resetPassword(String email) async {
    try {
      print("Sending password reset email to: $email");
      await _account.createRecovery(
        email: email,
        url: 'https://your-redirect-url.com', // Replace with your redirect URL
      );
      print("Password reset email sent to: $email");
      return "Password Reset Email Sent";
    } on AppwriteException catch (e) {
      print("Error sending password reset email: ${e.message}");
      return e.message ?? "Unknown error";
    }
  }

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final session = await _account.getSession(sessionId: 'current');
      return session != null;
    } on AppwriteException catch (e) {
      return false;
    }
  }
}*/

