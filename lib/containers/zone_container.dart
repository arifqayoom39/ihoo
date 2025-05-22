import 'dart:math';

import 'package:appwrite/models.dart';
import 'package:ihoo/contants/discount.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/products_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ZoneContainer extends StatefulWidget {
  final String category;
  const ZoneContainer({super.key, required this.category});

  @override
  State<ZoneContainer> createState() => _ZoneContainerState();
}

class _ZoneContainerState extends State<ZoneContainer> {
  Widget specialQuote({required int price, required int dis}) {
    return Row(
      children: [
        Text(
          "₹$price",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE41D36), // Warm red for price - creates urgency
          ),
        ),
        SizedBox(width: 8),
        Text(
          "₹${(price * 100) ~/ (100 - dis)}",
          style: TextStyle(
            fontSize: 14,
            decoration: TextDecoration.lineThrough,
            color: Color(0xFF878787),
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Color(0xFF2E7D32).withOpacity(0.1), // Deeper green - trust and value
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
              ),
            ],
          ),
          child: Text(
            "$dis% off",
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Document>>(
      future: DbService().readProducts(widget.category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 400,
              width: double.infinity,
              color: Colors.white,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.hasData) {
          List<Document> docs = snapshot.data!;

          List<ProductsModel> products = ProductsModel.fromJsonList(docs);

          if (products.isEmpty) {
            return Center(child: Text("No products available"));
          } else {
            return Container(
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          "${widget.category.substring(0, 1).toUpperCase()}${widget.category.substring(1)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF2874F0),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/specific", arguments: {
                              "name": widget.category,
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                "VIEW ALL",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: products.length > 4 ? 4 : products.length,
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/view_product",
                          arguments: products[i],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CachedNetworkImage(
                                  imageUrl: products[i].image,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => 
                                      Icon(Icons.error, color: Colors.red.shade300),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    products[i].name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  specialQuote(
                                    price: products[i].new_price,
                                    dis: int.parse(discountPercent(
                                      products[i].old_price,
                                      products[i].new_price,
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          return Center(child: Text("No Data Available"));
        }
      },
    );
  }
}

