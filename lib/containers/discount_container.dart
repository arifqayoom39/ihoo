import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/coupon_model.dart';

class DiscountContainer extends StatefulWidget {
  const DiscountContainer({super.key});

  @override
  State<DiscountContainer> createState() => _DiscountContainerState();
}

class _DiscountContainerState extends State<DiscountContainer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Document>>(
      future: DbService().readDiscounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          List<CouponModel> discounts = snapshot.data!
              .map((doc) => CouponModel.fromJson(doc.data, doc.$id))
              .toList();

          if (discounts.isEmpty) {
            return SizedBox();
          } else {
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/discount"),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_offer_rounded,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discounts[0].code,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            discounts[0].desc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: discounts[0].code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Coupon copied!'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          return SizedBox();
        }
      },
    );
  }
}



