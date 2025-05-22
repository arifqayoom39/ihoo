import 'package:appwrite/models.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/promo_banners_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PromoContainer extends StatefulWidget {
  const PromoContainer({super.key});

  @override
  State<PromoContainer> createState() => _PromoContainerState();
}

class _PromoContainerState extends State<PromoContainer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Document>>(
      future: DbService().readPromos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 180,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.white,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data != null) {
          List<PromoBannersModel> promos = snapshot.data!
              .map((doc) => PromoBannersModel.fromJson(doc.data))
              .toList();

          if (promos.isEmpty) {
            return SizedBox();
          } else {
            return CarouselSlider.builder(
              itemCount: promos.length,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/specific",
                        arguments: {"name": promos[index].category},
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: CachedNetworkImage(
                        imageUrl: promos[index].image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue.shade200,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, color: Colors.red.shade300),
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                viewportFraction: 1.0,
                aspectRatio: 16/7,
                enlargeCenterPage: false,
              ),
            );
          }
        }

        return SizedBox();
      },
    );
  }
}
