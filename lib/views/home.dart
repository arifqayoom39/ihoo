import 'package:ihoo/containers/category_container.dart';
import 'package:ihoo/containers/discount_container.dart';
import 'package:ihoo/containers/home_page_maker_container.dart';
import 'package:ihoo/containers/promo_container.dart';
import 'package:flutter/material.dart';
import 'package:ihoo/views/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Color(0xFF2874F0),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Best Deals",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Exclusive offers for you",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            PromoContainer(),
            DiscountContainer(),
            CategoryContainer(),
            HomePageMakerContainer()
          ],
        ),
      ),
    );
  }
}