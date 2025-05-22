import 'package:ihoo/providers/cart_provider.dart';
import 'package:ihoo/providers/user_provider.dart';
import 'package:ihoo/views/cart_page.dart';
import 'package:ihoo/views/home.dart';
import 'package:ihoo/views/orders_page.dart';
import 'package:ihoo/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {

  @override
  void initState() {
    Provider.of<UserProvider>(context,listen: false);
    super.initState();
  }

  int selectedIndex = 0;

  List pages = [
    HomePage(),
    OrdersPage(),
    CartPage(),
    ProfilePage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          selectedItemColor: Color(0xFF2874F0),
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home_selected.png',
                height: 24,
                width: 24,
                color: Colors.grey.shade400,
              ),
              activeIcon: Image.asset(
                'assets/images/home.png',
                height: 24,
                width: 24,
                color: Color(0xFF2874F0),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag_rounded, size: 26),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      Image.asset(
                        'assets/images/cart.png',
                        height: 24,
                        width: 24,
                        color: Colors.grey.shade400,
                      ),
                      if (value.carts.length > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${value.carts.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  );
                },
              ),
              activeIcon: Image.asset(
                'assets/images/cart_selected.png',
                height: 24,
                width: 24,
                color: Color(0xFF2874F0),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/profile.png',
                height: 24,
                width: 24,
                color: Colors.grey.shade400,
              ),
              activeIcon: Image.asset(
                'assets/images/profile_selected.png',
                height: 24,
                width: 24,
                color: Color(0xFF2874F0),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

/*
This is the home navbar of the app
 */