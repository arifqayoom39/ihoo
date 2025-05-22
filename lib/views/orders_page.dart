import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/orders_model.dart';
import 'view_order_page.dart'; // Import the view order page

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  totalQuantityCalculator(List<OrderProductModel> products) {
    int qty = 0;
    products.forEach((e) => qty += e.quantity);
    return qty;
  }

  Widget statusIcon(String status) {
    if (status == "PAID") {
      return statusContainer(
          text: "PAID", bgColor: Color(0xFFE7F0FF), textColor: Color(0xFF2874F0));
    } else if (status == "ON_THE_WAY") {
      return statusContainer(
          text: "ON THE WAY", bgColor: Color(0xFFFFF5E5), textColor: Color(0xFFFF9F00));
    } else if (status == "DELIVERED") {
      return statusContainer(
          text: "DELIVERED", bgColor: Color(0xFFE6F4EA), textColor: Color(0xFF1BA672));
    } else {
      return statusContainer(
          text: "CANCELED", bgColor: Color(0xFFFFEBEE), textColor: Color(0xFFFF4343));
    }
  }

  Widget statusContainer({required String text, required Color bgColor, required Color textColor}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Changed to white background
      appBar: AppBar(
        title: Text(
          "My Orders",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2874F0),
        elevation: 0,
      ),
      body: FutureBuilder<List<Document>>(
        future: DbService().readOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<OrdersModel> orders = OrdersModel.fromJsonList(snapshot.data!);
            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, 
                      size: 80, 
                      color: Colors.grey[400]
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No orders yet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 4),
              itemCount: orders.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.pushNamed(
                    context, 
                    "/view_order", 
                    arguments: orders[index]
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${orders[index].id.substring(0, 8)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF2874F0),
                              ),
                            ),
                            statusIcon(orders[index].status),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${totalQuantityCalculator(orders[index].products)} Items • ₹${orders[index].total}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Ordered on ${DateTime.fromMillisecondsSinceEpoch(orders[index].created_at).toLocal().toString().split(' ')[0]}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2874F0)),
            ),
          );
        },
      ),
    );
  }
}








