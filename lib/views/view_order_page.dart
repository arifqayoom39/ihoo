import 'package:flutter/material.dart';
import 'package:ihoo/models/orders_model.dart';
import '../containers/modify_popup.dart';

class ViewOrderPage extends StatefulWidget {
  const ViewOrderPage({super.key});

  @override
  State<ViewOrderPage> createState() => _ViewOrderPageState();
}

class _ViewOrderPageState extends State<ViewOrderPage> {
  Widget _buildStatusTimeline(String status) {
    final stages = ['PAID', 'ON_THE_WAY', 'DELIVERED'];
    final currentIndex = stages.indexOf(status);
    
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: stages.asMap().entries.map((entry) {
          final isCompleted = entry.key <= currentIndex;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? Color(0xFF2874F0) : Colors.grey[300],
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? Color(0xFF2874F0) : Colors.grey,
                        fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (entry.key < stages.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? Color(0xFF2874F0) : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrdersModel;
    
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Details",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "#${args.id.substring(0, 8)}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF2874F0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (args.status != "CANCELED") _buildStatusTimeline(args.status),
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivery Address",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    args.name,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(args.phone),
                  Text(args.address),
                ],
              ),
            ),
            // Products List
            ...args.products.map((e) => Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      e.image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Qty: ${e.quantity}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          "₹${e.single_price} x ${e.quantity}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          "₹${e.total_price}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2874F0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
            // Price Details
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Discount"),
                      Text(
                        "- ₹${args.discount}",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "₹${args.total}",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (args.status == "PAID" || args.status == "ON_THE_WAY")
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ModifyPopup(order: args),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2874F0),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text("Modify Order"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
