import 'package:appwrite/models.dart';
import 'package:ihoo/containers/banner_container.dart';
import 'package:ihoo/containers/zone_container.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/categories_model.dart';
import 'package:ihoo/models/promo_banners_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomePageMakerContainer extends StatefulWidget {
  const HomePageMakerContainer({super.key});

  @override
  State<HomePageMakerContainer> createState() => _HomePageMakerContainerState();
}

class _HomePageMakerContainerState extends State<HomePageMakerContainer> {
  int min = 0;

  // Method to calculate the minimum value
  int minCalculator(int a, int b) {
    return min = a > b ? b : a;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Document>>(
      future: DbService().readCategories(), // Fetching categories from Appwrite
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.white,
            child: Container(height: 400, width: double.infinity),
          );
        }

        if (snapshot.hasError) {
          print("Error fetching categories: ${snapshot.error}");
          return Center(child: Text('Failed to load categories.'));
        }

        if (snapshot.hasData) {
          List<CategoriesModel> categories = CategoriesModel.fromJsonList(snapshot.data!);

          if (categories.isEmpty) {
            return Center(child: Text('No categories found.'));
          } else {
            return FutureBuilder<List<Document>>(
              future: DbService().readBanners(), // Fetching banners from Appwrite
              builder: (context, bannerSnapshot) {
                if (bannerSnapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    child: Container(height: 200, width: double.infinity),
                  );
                }

                if (bannerSnapshot.hasError) {
                  print("Error fetching banners: ${bannerSnapshot.error}");
                  return Center(child: Text('Failed to load banners.'));
                }

                if (bannerSnapshot.hasData) {
                  List<PromoBannersModel> banners = PromoBannersModel.fromJsonList(bannerSnapshot.data!);

                  if (banners.isEmpty) {
                    return Center(child: Text('No banners found.'));
                  } else {
                    return Column(
                      children: [
                        for (int i = 0; i < minCalculator(categories.length, banners.length); i++)
                          Column(
                            children: [
                              ZoneContainer(category: categories[i].name),
                              BannerContainer(
                                image: banners[i].image,
                                category: banners[i].category,
                              ),
                            ],
                          ),
                      ],
                    );
                  }
                } else {
                  return Center(child: Text('No banners found.'));
                }
              },
            );
          }
        } else {
          return Center(child: Text('No categories found.'));
        }
      },
    );
  }
}
