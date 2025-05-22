/*import 'package:ihoo/controllers/auth_service.dart';
import 'package:ihoo/providers/cart_provider.dart';
import 'package:ihoo/providers/user_provider.dart';
import 'package:ihoo/views/cart_page.dart';
import 'package:ihoo/views/checkout_page.dart';
import 'package:ihoo/views/discount_page.dart';
import 'package:ihoo/views/home_nav.dart';
import 'package:ihoo/views/login.dart';
import 'package:ihoo/views/orders_page.dart';
import 'package:ihoo/views/signup.dart';
import 'package:ihoo/views/specific_products.dart';
import 'package:ihoo/views/update_profile.dart';
import 'package:ihoo/views/view_order_page.dart';
import 'package:ihoo/views/splash_screen.dart';
import 'package:ihoo/views/view_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ihoo/services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("Loading environment variables...");
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully.");

    runApp(const MyApp());
  } catch (e) {
    print("Error during initialization: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Ihoo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            // Check for updates when app starts
            Future.delayed(Duration.zero, () {
              UpdateService.checkForUpdate(context);
            });
            return SplashScreen();
          },
        ),
        routes: {
          "/login": (context) => LoginPage(),
          "/home": (context) => HomeNav(),
          "/signup": (context) => SignUpPage(),
          "/update_profile": (context) => UpdateProfile(),
          "/discount": (context) => DiscountPage(),
          "/specific": (context) => SpecificProducts(),
          "/view_product": (context) => ViewProduct(),
          "/cart": (context) => CartPage(),
          "/checkout": (context) => CheckoutPage(),
          "/orders": (context) => OrdersPage(),
          "/view_order": (context) => ViewOrderPage(),
        },
      ),
    );
  }
}*/

import 'package:ihoo/providers/cart_provider.dart';
import 'package:ihoo/providers/user_provider.dart';
import 'package:ihoo/views/cart_page.dart';
import 'package:ihoo/views/checkout_page.dart';
import 'package:ihoo/views/discount_page.dart';
import 'package:ihoo/views/home_nav.dart';
import 'package:ihoo/views/login.dart';
import 'package:ihoo/views/orders_page.dart';
import 'package:ihoo/views/signup.dart';
import 'package:ihoo/views/specific_products.dart';
import 'package:ihoo/views/update_profile.dart';
import 'package:ihoo/views/view_order_page.dart';
import 'package:ihoo/views/splash_screen.dart';
import 'package:ihoo/views/view_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("Loading environment variables...");
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully.");
    runApp(const MyApp());
  } catch (e) {
    print("Error during initialization: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building MyApp widget...");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Ihoo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: {
          "/": (context) {
            print("Navigating to SplashScreen...");
            return SplashScreen();
          },
          "/login": (context) {
            print("Navigating to LoginPage...");
            return LoginPage();
          },
          "/home": (context) {
            print("Navigating to HomeNav...");
            return HomeNav();
          },
          "/signup": (context) {
            print("Navigating to SignUpPage...");
            return SignUpPage();
          },
          "/update_profile": (context) {
            print("Navigating to UpdateProfile...");
            return UpdateProfile();
          },
          "/discount": (context) {
            print("Navigating to DiscountPage...");
            return DiscountPage();
          },
          "/specific": (context) {
            print("Navigating to SpecificProducts...");
            return SpecificProducts();
          },
          "/view_product": (context) {
            print("Navigating to ViewProduct...");
            return ViewProduct();
          },
          "/cart": (context) {
            print("Navigating to CartPage...");
            return CartPage();
          },
          "/checkout": (context) {
            print("Navigating to CheckoutPage...");
            return CheckoutPage();
          },
          "/orders": (context) {
            print("Navigating to OrdersPage...");
            return OrdersPage();
          },
          "/view_order": (context) {
            print("Navigating to ViewOrderPage...");
            return ViewOrderPage();
          },
        },
      ),
    );
  }
}

